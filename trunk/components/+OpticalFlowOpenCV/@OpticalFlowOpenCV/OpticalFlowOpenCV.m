classdef OpticalFlowOpenCV < OpticalFlowOpenCV.OpticalFlowOpenCVConfig & tom.Measure
  
  properties (SetAccess = private, GetAccess = private)
    sensor
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = ['Implements a trajectory measure based on the computation of optical flow between image pairs. ', ...
          'Depends on the OpenCV 2.0.0 library. ', ...
          'Depends on a antbed DataContainer that has at least one antbed Camera object.'];
      end
      tom.Measure.connect(name, @componentDescription, @OpticalFlowOpenCV.OpticalFlowOpenCV);
    end
  end
  
  methods (Access = public)
    function this = OpticalFlowOpenCV(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);
      if(this.verbose)
        fprintf('\nInitializing %s\n', class(this));
      end
      
      % compile mex file if necessary
      if(this.overwriteMEX)
        if(this.verbose)
          fprintf('\nCompiling mex wrapper for OpenCV...');
        end

        % Locate OpenCV libraries
        userPath = path;
        userWarnState = warning('off', 'all'); % see MATLAB Solution ID 1-5JUPSQ
        addpath(getenv('LD_LIBRARY_PATH'), '-END');
        addpath(getenv('PATH'), '-END');
        warning(userWarnState);
        if(ispc)
          libdir = fileparts(which('cv200.lib'));
        elseif(ismac)
          libdir = fileparts(which('libcv.dylib'));
        else
          libdir = fileparts(which('libcv.so'));
        end
        path(userPath);

        % Compile and link against OpenCV libraries
        userDirectory = pwd;
        cd(fullfile(fileparts(mfilename('fullpath')), 'private'));
        try
          if(ispc)
            mex('mexOpticalFlowOpenCV.cpp', ['-L"', libdir, '"'], '-lcv200', '-lcxcore200');
          elseif(ismac)
            mex('mexOpticalFlowOpenCV.cpp', ['-L"', libdir, '"'], '-lcv', '-lcxcore');
          else
            mex('mexOpticalFlowOpenCV.cpp', ['-L"', libdir, '"'], '-lcv', '-lcxcore');
          end
        catch err
          details = err.message;
          details = [details, ' Failed to compile against local OpenCV 2.0.0 libraries.'];
          details = [details, ' Please see the Readme file distributed with OpenCV.'];
          details = [details, ' The following files must be either in the system PATH'];
          details = [details, ' or LD_LIBRARY_PATH:'];
          if(ispc)
            details = [details, ' cv200.lib cv200.dll cxcore200.lib cxcore200.dll'];
          elseif(ismac)
            details = [details, ' libcv.dylib libcxcore.dylib'];           
          else
            details = [details, ' libcv.so libcxcore.so'];
          end
          cd(userDirectory);
          error(details);
        end
        cd(userDirectory);
        if(this.verbose)
          fprintf('done');
        end
      end
        
      if(~strncmp(uri, 'antbed:', 7))
        error('URI scheme not recognized');
      end
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      list = container.listSensors('antbed.Camera');
      this.sensor = container.getSensor(list(1));                 
    end
    
    function refresh(this, x)
      this.sensor.refresh(x);
    end
    
    function flag = hasData(this)
      flag = this.sensor.hasData();
    end
    
    function na = first(this)
      na = this.sensor.first();
    end
    
    function na = last(this)
      na = this.sensor.last();
    end
    
    function time = getTime(this, n)
      time = this.sensor.getTime(n);
    end
    
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(this.sensor.hasData())
        naMin = max([naMin, this.sensor.first(), nbMin-uint32(1)]);
        naMax = min([naMax, this.sensor.last()-uint32(1), nbMax-uint32(1)]);
        a = naMin:naMax;
        if(naMax>=naMin)
          edgeList = tom.GraphEdge(a, a+uint32(1));
        end
      end
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)
      nodeA = graphEdge.first;
      nodeB = graphEdge.second;
      
      % return 0 if the specified edge is not found in the graph
      isAdjacent = ((nodeA+uint32(1))==nodeB) && this.sensor.hasData() && ...
        (nodeA>=this.sensor.first()) && (nodeB<=this.sensor.last());
      if(~isAdjacent)
        cost = 0;
        return;
      end

      % return NaN if the graph edge extends outside of the trajectory domain
      ta = this.sensor.getTime(nodeA);
      tb = this.sensor.getTime(nodeB);
      interval = x.domain();
      if(ta<interval.first)
        cost = NaN;
        return;
      end

      poseA = x.evaluate(ta);
      poseB = x.evaluate(tb);

      data = edgeCache(nodeA, nodeB, this);

      u = transpose(data.pixB(:, 1)-data.pixA(:, 1));
      v = transpose(data.pixB(:, 2)-data.pixA(:, 2));

      Ea = Quat2Euler(poseA.q);
      Eb = Quat2Euler(poseB.q);

      translation = [poseB.p(1)-poseA.p(1);
        poseB.p(2)-poseA.p(2);
        poseB.p(3)-poseA.p(3)];
      rotation = [Eb(1)-Ea(1);
        Eb(2)-Ea(2);
        Eb(3)-Ea(3)];
      [uvr, uvt] = generateFlowSparse(this, translation, rotation, transpose(data.pixA), nodeA);

      cost = computeCost(this, u, v, uvr, uvt);
    end  
  end
  
  methods (Access = private)
    function data = processEdge(this, na, nb)
      persistent handle

      imageA = this.sensor.getImage(na);
      imageB = this.sensor.getImage(nb);

      switch( this.sensor.interpretLayers() )
      case {'rgb', 'rgbi'}
        imageA = double(rgb2gray(imageA(:, :, 1:3)));
        imageB = double(rgb2gray(imageB(:, :, 1:3)));
      case {'hsv', 'hsvi'}
        imageA = double(imageA(:, :, 3));
        imageB = double(imageB(:, :, 3));
      otherwise
        imageA = double(imageA);
        imageB = double(imageB);
      end

      [pixA, pixB] = mexOpticalFlowOpenCV(double(imageA), double(imageB), double(this.isDense), this.windowSize, this.levels);
      data = struct('pixA', pixA, 'pixB', pixB);

      if(this.displayFlow)
        imageA = imageA/255;
        imageB = imageB/255;
        if(isempty(handle))
          handle = figure;
        else
          figure(handle);
          clf(handle);
        end
        imshow(cat(3, zeros(size(imageA)), 0.5+(imageA-imageB)/2, 0.5+(imageB-imageA)));
        hold('on');
        pixA = pixA+1;
        pixB = pixB+1;
        line([pixA(:, 1), pixB(:, 1)]', [pixA(:, 2), pixB(:, 2)]', 'Color', 'r');
        hold('off');
        drawnow;
      end
    end
  end
end

% Caches data indexed by individual indices
function data = nodeCache(n, obj)
  persistent cache
  nKey = ['n', sprintf('%d', n)];
  if( isfield(cache, nKey) )
    data = cache.(nKey);
  else
    data = obj.processNode(n);
    cache.(nKey) = data;
  end
end

% Caches data indexed by pairs of indices
function data = edgeCache(nA, nB, obj)
  persistent cache
  nAKey = ['a', sprintf('%d', nA)];
  nBKey = ['b', sprintf('%d', nB)];
  if( isfield(cache, nAKey)&&isfield(cache.(nAKey), nBKey) )
    data = cache.(nAKey).(nBKey);
  else
    data = obj.processEdge(nA, nB);
    cache.(nAKey).(nBKey) = data;
  end
end
