classdef MacCam < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & hidi.Camera
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  
  properties (Constant = true, GetAccess = private)
    na = uint32(1);
    steps = uint32(120);
    strides = uint32(160);
    layers = 'rgb';
    clockBase = [1980, 1, 6, 0, 0, 0];
    defaultRate = 1/30;
    fileFormat = '%05d.png';
    vlcErrorText = 'MacBook camera depends on VLC Media Player for OS X';
    timeOutText = 'Timeout while waiting for camera initialization';
  end
  
  properties (Access = private)
    focal
    nb
    rate
    ready
    initialTime
    refTime
    timeZoneOffset 
  end
  
  methods (Access = public)
    function this = MacCam(initialTime)
      this = this@hidi.Camera();
      if(this.verbose)
        fprintf('\nInitializing %s', class(this));
      end
      
      this.focal = double(this.strides)*cot(this.cameraFieldOfView/2);
      
      if(this.overwrite)
        calendar = java.util.GregorianCalendar;
        zone = calendar.getTimeZone;
        this.timeZoneOffset = (zone.getRawOffset+zone.getDSTSavings)/1000;

        if(~exist(this.localCache, 'dir'))
          mkdir(this.localCache);
        end
        delete(fullfile(this.localCache, '*.png'));
        delete(fullfile(this.localCache, '*.swp'));

        if(~exist(this.vlcPath, 'file'))
          error(this.vlcErrorText);
        end
        startcmd = [sprintf('%s qtcapture:// ', this.vlcPath), ...
          '--vout=dummy --aout=dummy --video-filter=scene --scene-format=png --scene-prefix="" ', ...
          sprintf('--scene-width=%d --scene-height=%d ', this.strides, this.steps), ...
          sprintf('--scene-ratio=%d --scene-path=%s ', this.cameraIncrement, this.localCache), ...
          '2> /dev/null &'];
        unix(startcmd);

        this.ready = false;
        t0 = clock;
        t1 = clock;
        while(etime(t1, t0)<this.timeOut)
          if(isValid(this, uint32(1)))
            t1 = clock;
            this.ready = true;
            break;
          end
          t1 = clock;
        end
        if(~this.ready)
          error(this.timeOutText);
        end
        this.ready = false;
        t2 = clock;
        while(etime(t2, t1)<(this.timeOut+0.2*this.cameraIncrement))
          if(isValid(this, uint32(2)))
            t2 = clock;
            this.ready = true;
            break;
          end
          t2 = clock;
        end
        if(~this.ready)
          error(this.timeOutText);
        end
        this.rate = etime(t2, t1);
        this.initialTime = etime(t1, this.clockBase)-this.rate;
        this.refTime = t1;
        this.nb = uint32(2);
      else
        this.initialTime = initialTime;
        this.rate = this.defaultRate;
        this.ready = false;
        this.nb = this.na;
        while(this.isValid(this.nb))
          this.nb = this.nb+uint32(1);
          this.ready = true;
        end
      end
    end

    function refresh(this, x)
      assert(isa(x, 'tom.Trajectory'));
      if(this.overwrite)
        kRef = this.nb;
        while(isValid(this, this.nb+uint32(1)))
          time = clock;
          this.nb = this.nb+uint32(1);
        end
        if(this.nb>kRef)
          numImages = double(this.nb-this.na+uint32(1)); % adds one to account for behavior of isValid
          this.rate = etime(time, this.refTime)/numImages; 
        end
      end
    end
    
    function flag = hasData(this)
      flag = this.ready;
    end
    
    function na = first(this)
      na = this.na;
    end

    function nb = last(this)
      nb = this.nb;
    end
    
    function time = getTime(this, n)
      assert(all(n>=this.na));
      assert(all(n<=this.nb));
      if(this.overwrite)
        time = this.initialTime+this.rate*double(n-this.na)-this.timeZoneOffset;
      else
        time = this.initialTime+this.rate*double(n-this.na);
      end
    end
    
    function str = interpretLayers(this)
      str = this.layers;
    end
    
    function num = numSteps(this)
      num = this.steps;
    end
    
    function num = numStrides(this)
      num = this.strides;
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
      c1((c1<=0.0)|(c1>1.0)) = NaN;
      r = this.focal.*sqrt(1.0-c1.*c1)./c1; % r = f*tan(acos(c1))
      theta = atan2(c3, c2);
      mc = (m-1.0)/2.0;
      nc = (n-1.0)/2.0;
      steps = r.*sin(theta)+mc;
      strides = r.*cos(theta)+nc;
      outside = ((-0.5>steps(:))|(-0.5>strides(:))|(strides(:)>(n-0.5))|(steps(:)>(m-0.5)));
      steps(outside) = NaN;
      strides(outside) = NaN;
    end
    
    function [c1, c2, c3] = inverseProjection(this, strides, steps)
      m = double(this.steps);
      n = double(this.strides);
      outside = ((-0.5>steps(:))|(-0.5>strides(:))|(strides(:)>(n-0.5))|(steps(:)>(m-0.5)));
      steps(outside) = NaN;
      strides(outside) = NaN;
      mc = (m-1)/2.0;
      nc = (n-1)/2.0;
      steps = steps-mc;
      strides = strides-nc;
      r = sqrt(steps.*steps+strides.*strides);
      alpha = atan(r./this.focal);
      theta = atan2(steps, strides);
      c1 = cos(alpha);
      c2 = sin(alpha).*cos(theta);
      c3 = sin(alpha).*sin(theta);
    end
    
    function img = getImageUInt8(this, n, layer, img) %#ok input not used
      assert(n>=this.na);
      assert(n<=this.nb);
      num = this.na+this.cameraIncrement*n;
      img = imread(fullfile(this.localCache, sprintf(this.fileFormat, num)));
      img = img(:, :, layer+1);
    end
    
    function img = getImageDouble(this, n, layer, img)
      img = double(this.getImageUInt8(n, layer, uint8(img*255.0)))/255.0;
    end
    
    % Stops the image capture process
    function delete(this)
      if(this.overwrite)
        [base, name, ext] = fileparts(this.vlcPath);
        unix(['killall -9 ', name, ext]);
      end
    end
  end
  
  methods (Access = private)
    % checks for the next image being written to validate the current image
    function flag = isValid(this, n)
      num = this.na+this.cameraIncrement*(n+1); % adds one
      fname = fullfile(this.localCache, sprintf(this.fileFormat, num));
      flag = exist(fname, 'file');
    end
  end
end
