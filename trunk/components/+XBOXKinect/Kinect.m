classdef Kinect < XBOXKinect.XBOXKinectConfig & hidi.Camera
  properties (Constant = true)
    steps = uint32(480);
    strides = uint32(640);
    appName = 'kinectapp';
    fileFormat = '%06d';
    maxDepth = 4.9; % sensitive parameter
    minDepth = 0.8; % sensitive parameter
    maxInt = 2^11;
    localCache = fileparts(mfilename('fullpath'));
    layers = 'rgbd';
  end
  
  properties
    depthFocal
    na
    nb
    ready
  end
  
  methods (Access = private)
    function data = getDepth(this, n)
      assert(this.ready)
      fid = fopen(fullfile(this.localCache, ['depth', num2str(n, this.fileFormat), '.dat']));
      data = fread(fid, this.strides*this.steps,'*uint16');
      fclose(fid);
      data = reshape(data, [this.strides, this.steps])';
      data = double(data);
      bad = logical(data(:)>=(this.maxInt-1.0));
      M = [this.maxDepth, this.maxInt/2.0*this.maxDepth; this.minDepth, this.maxInt/4.0*this.minDepth];
      a = M\[1.0; 1.0];
      data = 1.0./(a(1)+a(2)*data); % 1.0./(3.3309-0.0030711*data)
      [pix1, pix2] = ndgrid(0.0:(double(this.steps)-1.0), 0.0:(double(this.strides)-1.0));
      f = this.depthInverseProjection(pix2, pix1);
      data = data./reshape(f, this.steps, this.strides);
      data(bad) = nan;
    end
  end
  
  methods (Access = public)
    function this = Kinect(initialTime)
      this = this@hidi.Camera();
      if(this.verbose)
        fprintf('\nInitializing %s', class(this));
      end
      
      this.depthFocal = double(this.strides)*cot(this.depthFieldOfView/2);      
      
      if(this.overwrite)
        delete(fullfile(this.localCache, 'depth*.dat'));
        delete(fullfile(this.localCache, 'video*.dat'));
        delete(fullfile(this.localCache, 'time*.dat'));

        % Compile and link against freenect libraries
        userDirectory = pwd;
        cd(this.localCache);
        if(this.recompile||(~exist(this.appName, 'file')))
          if(this.verbose)
            fprintf('\nCompiling application for Kinect sensor...');
          end
          try
            unix(['gcc ', this.appName,'.cpp -o ', this.appName]);
          catch err
            details = err.message;
            details = [details, ' Failed to compile using local freenect libraries.'];
            details = [details, ' Try compiling ', this.appName, 'externally.'];
            cd(userDirectory);
            error(details);
          end
          if(this.verbose)
            fprintf('done');
          end
        end
        unix(fullfile(this.localCache, [this.appName,' &']));
        cd(userDirectory);
      end
      
      this.na = uint32(0);
      this.nb = uint32(0);
  
      this.ready = false;
      refTime = clock;
      while(etime(clock, refTime)<this.timeOut)
        if(this.isValid(0))
          this.ready = true;
          break;
        end
      end
      
      this.refresh(tom.DynamicModel.create('tom', initialTime, ''));
    end

    function refresh(this, x)
      assert(isa(x, 'tom.Trajectory'));
      while(this.isValid(this.nb+uint32(1)))
        this.nb = this.nb+uint32(1);
        this.ready = true;
      end
    end
    
    function flag = hasData(this)
      flag = this.ready;
    end
    
    function na = first(this)
      assert(this.ready)
      na = this.na;
    end

    function nb = last(this)
      assert(this.ready)      
      nb = this.nb;
    end
    
    function time = getTime(this, n)
      assert(this.ready)
      time = zeros(size(n));
      for k = 1:numel(n)
        time(k) = dlmread(fullfile(this.localCache, ['time', num2str(n(k), this.fileFormat), '.dat']));
      end
    end
    
    function str = interpretLayers(this)
      str = this.layers;
    end
    
    function num = numStrides(this)
      num = this.strides;
    end
      
    function num = numSteps(this)
      num = this.steps;
    end
    
    function s = strideMin(this, node)
      assert(isa(this, 'hidi.Camera'));
      assert(isa(node, 'uint32'));
      s = uint32(0);
    end
    
    function s = strideMax(this, node)
      assert(isa(node, 'uint32'));
      s = this.numStrides()-uint32(1);
    end
    
    function s = stepMin(this, node)
      assert(isa(this, 'hidi.Camera'));
      assert(isa(node, 'uint32'));
      s = uint32(0);
    end
    
    function s = stepMax(this, node)
      assert(isa(node, 'uint32'));
      s = this.numSteps()-uint32(1);
    end
    
    function [strides, steps] = projection(this, c1, c2, c3)
      m = double(this.steps);
      n = double(this.strides);
      c1((c1<=0.0)|(c1>1.0)) = nan;
      r = this.depthFocal*sqrt(1.0-c1.*c1)./c1; % r = f*tan(acos(c1))
      theta = atan2(c3, c2);
      mc = (m-1.0)/2.0;
      nc = (n-1.0)/2.0;
      steps = r.*sin(theta)+mc;
      strides = r.*cos(theta)+nc;
      outside = ((-0.5>steps(:))|(-0.5>strides(:))|(strides(:)>(n-0.5))|(steps(:)>(m-0.5)));
      steps(outside) = nan;
      strides(outside) = nan;
    end
    
    function [c1, c2, c3] = inverseProjection(this, strides, steps)
      m = double(this.steps);
      n = double(this.strides);
      outside = ((-0.5>steps(:))|(-0.5>strides(:))|(strides(:)>(n-0.5))|(steps(:)>(m-0.5)));
      steps(outside) = nan;
      strides(outside) = nan;
      mc = (m-1.0)/2.0;
      nc = (n-1.0)/2.0;
      steps = steps-mc;
      strides = strides-nc;
      r = sqrt(steps.*steps+strides.*strides);
      alpha = atan(r/this.depthFocal);
      theta = atan2(steps, strides);
      c1 = cos(alpha);
      c2 = sin(alpha).*cos(theta);
      c3 = sin(alpha).*sin(theta);
    end
    
    function img = getImageUInt8(this, n, layer, img) %#ok input not used
      assert(this.ready)
      switch(layer)
        case {uint32(0), uint32(1), uint32(2)}
          fid = fopen(fullfile(this.localCache, ['video', num2str(n, this.fileFormat), '.dat']));
          img = fread(fid, this.steps*this.strides*3, '*uint8');
          fclose(fid);
          img = permute(reshape(img, [3, this.strides, this.steps]), [3, 2, 1]);
          img = img(:, :, layer+1);
        case uint32(3)
          img = uint32(this.getDepth(n));
        otherwise
          error('Kinect: Unrecognized layer.')
      end
    end
    
    function img = getImageDouble(this, n, layer, img)
      switch(layer)
        case {uint32(0), uint32(1), uint32(2)}
          img = double(this.getImageUInt8(n, layer, uint8(img*255.0)))/255.0;
        case uint32(3)
          img = this.getDepth(n);
        otherwise
          error('Kinect: Unrecognized layer.')
      end
    end

    % Stops the image capture process
    function delete(this)
      if(this.overwrite)
        unix(['killall -INT ', this.appName]);
      end
    end
  end
  
  methods (Access = private)
    function flag = isValid(this, n)
      flag = exist(fullfile(this.localCache, ['time', num2str(n, this.fileFormat), '.dat']), 'file');
    end
  end
end
