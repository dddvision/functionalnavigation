classdef OpticalFlowOpenCV < OpticalFlowOpenCV.OpticalFlowOpenCVConfig & tom.Measure
  
  properties (SetAccess = private, GetAccess = private)
    sensor
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = ['Implements a trajectory measure based on the computation of optical flow between image pairs. ', ...
          'Depends on the OpenCV library.', ...
          'Depends on a antbed.DataContainer that has at least one antbed.Camera object.'];
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
        
      if(~exist('mexOpticalFlowOpenCV', 'file'))
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
          details = [details, ' Failed to compile against local OpenCV libraries.'];
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
      list = listSensors(container, 'antbed.Camera');
      this.sensor = getSensor(container, list(1));                 
    end
    
    function refresh(this, x)
      this.sensor.refresh(x);
    end
    
    function flag = hasData(this)
      flag = hasData(this.sensor);
    end
    
    function na = first(this)
      na = first(this.sensor);
    end
    
    function na = last(this)
      na = last(this.sensor);
    end
    
    function time = getTime(this, n)
      time = getTime(this.sensor, n);
    end
    
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(hasData(this.sensor))
        naMin = max([naMin, first(this.sensor), nbMin-uint32(1)]);
        naMax = min([naMax, last(this.sensor)-uint32(1), nbMax-uint32(1)]);
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
      isAdjacent = ((nodeA+uint32(1))==nodeB) && hasData(this.sensor) && ...
        (nodeA>=first(this.sensor)) && (nodeB<=last(this.sensor));
      if(~isAdjacent)
        cost = 0;
        return;
      end

      % return NaN if the graph edge extends outside of the trajectory domain
      ta = getTime(this.sensor, nodeA);
      tb = getTime(this.sensor, nodeB);
      interval = domain(x);
      if(ta<interval.first)
        cost = NaN;
        return;
      end

      poseA = evaluate(x, ta);
      poseB = evaluate(x, tb);

      data = computeIntermediateDataCache(this, nodeA, nodeB);

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
  
end
