classdef KLTOpenCV < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant = true, GetAccess = private)
    halfwin = 5;
  end
  
  properties (GetAccess = private, SetAccess = private)
    camera
    numLevels
  end
  
  methods (Access = public, Static = true)
    function this = KLTOpenCV(initialTime, camera)
      this = this@FastPBM.SparseTracker(initialTime);
      
      % store camera handle
      this.camera = camera;
      
      % compile mex file if necessary
      if(this.overwriteMEX||(~exist('mexOpticalFlowOpenCV', 'file')))
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
    end
  end
  
  methods (Abstract = false, Access = public)
   function refresh(this, x)
      this.camera.refresh(x);
    end
    
    function flag = hasData(this)
      flag = this.camera.hasData();
    end
    
    function n = first(this)
      n = this.camera.first();
    end
    
    function n = last(this)
      n = this.camera.last();
    end
    
    function time = getTime(this, n)
      time = this.camera.getTime(n);
    end

    function [rayA, rayB] = findMatches(this, nodeA, nodeB)
      data = FastPBM.edgeCache(nodeA, nodeB, this);
      rayA = data.rayA;
      rayB = data.rayB;
    end

    function data = processEdge(this, nodeA, nodeB)
      imageA = this.prepareImage(nodeA);
      imageB = this.prepareImage(nodeB);
      [pixA, pixB] = mexOpticalFlowOpenCV(imageA, imageB, 0, this.halfwin*2+1, this.numLevels);
      pixA = pixA';
      pixB = pixB';
      xA = pixA(2, :);
      yA = pixA(1, :);
      xB = pixB(2, :);
      yB = pixB(1, :);
      
      % keep valid points only
      good = ~(isnan(xB)|isnan(yB));
      xB = xB(good);
      yB = yB(good);
      xA = xA(good);
      yA = yA(good);

      [fA, rA, dA] = this.camera.inverseProjection(yA, xA);
      [fB, rB, dB] = this.camera.inverseProjection(yB, xB);
      data = struct('rayA', [fA; rA; dA], 'rayB', [fB; rB; dB]);
    end
    
    % Prepare an image for processing
    %
    % Computes number of pyramid levels
    % Gets an image from the camera
    % Converts to grayscale and normalizes to the range [0,1]
    function img = prepareImage(this, node)
      if(isempty(this.numLevels))
        steps = this.camera.numSteps();
        strides = this.camera.numStrides();
        pix = [double(strides)-2; double(steps)-1]/2;
        pix = [pix, pix+[1; 0]];
        [f, r] = this.camera.inverseProjection(pix(1, :), pix(2, :));
        angularSpacing = acos(acos(f(1)*f(2)+r(1)*r(2)));
        maxPix = this.maxSearch/angularSpacing;
        this.numLevels = uint32(1+ceil(log2(maxPix/this.halfwin)));
      end
      img = this.camera.getImageDouble(node, uint32(0), uint8(0)); % process red only for speed
    end
  end
  
end
