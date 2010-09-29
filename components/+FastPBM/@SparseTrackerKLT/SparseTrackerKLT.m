classdef SparseTrackerKLT < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant=true,GetAccess=private)
    halfwin = 5;
    thresh = 0.98;
    cornerMethod = 'Harris';
  end
  
  properties (GetAccess=private,SetAccess=private)
    camera
    nodeA
    pyramidA
    xA
    yA
    nodeOffset
    features
    uniqueIndex
    uniqueNext
    firstTrack
    numLevels
    figureHandle
    plotHandle
  end
  
  methods (Access=public, Static=true)
    function this = SparseTrackerKLT(camera)
      this.camera = camera;
      
      if(~exist('mexTrackFeaturesKLT','file'))
        userDirectory = pwd;
        cd(fullfile(fileparts(mfilename('fullpath')),'private'));
        try
          mex('mexTrackFeaturesKLT.cpp');
        catch err
          cd(userDirectory);
          error(err.message);
        end
        cd(userDirectory);
      end
      
      this.firstTrack = true;
      this.track();
    end
  end
  
  methods (Abstract=false, Access=public, Static=false)
    function refresh(this)
      this.camera.refresh();
      this.track();
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
    
    function flag = isFrameDynamic(this)
      flag = this.camera.isFrameDynamic();
    end    
    
    function pose = getFrame(this, node)
      pose = this.camera.getFrame(node);
    end
    
    function num = numFeatures(this, node)
      num = numel(this.features(node-this.nodeOffset).id);
    end
    
    function id = getFeatureID(this, node, localIndex)
      id = this.features(node-this.nodeOffset).id(localIndex+uint32(1));
    end
    
    function ray = getFeatureRay(this, node, localIndex)
      ray = this.features(node-this.nodeOffset).ray(:, localIndex+uint32(1));
    end
  end
  
  methods (Access=private)
    % perform tracking
    function track(this)
      
      % only attempt to track if the camera has data
      if(this.camera.hasData())
        
        % process first image
        if(this.firstTrack)
          this.nodeA = this.camera.first();
          this.nodeOffset = this.nodeA-uint32(1);
          this.pyramidA = buildPyramid(this.prepareImage(this.nodeA), this.numLevels);
          [this.xA, this.yA] = selectFeatures(this, this.pyramidA{1}.gx, this.pyramidA{1}.gy, this.maxFeatures);
          this.uniqueIndex = getUniqueIndices(this, numel(this.xA));
          this.features.id = this.uniqueIndex;
          this.features.ray = this.camera.inverseProjection([this.yA;this.xA]-1, this.nodeA);
          this.firstTrack = false;
        end

        % if there are any new images
        nodeLast = this.camera.last();
        nodeB = this.nodeA+uint32(1);
        if(nodeLast>=nodeB)
          
          % estimate the feature locations in imageB
          xB = this.xA;
          yB = this.yA;
          
          % process all new images
          for nodeB = nodeB:nodeLast
            
            % build the image pyramid with gradients
            pyramidB = buildPyramid(this.prepareImage(nodeB), this.numLevels);

            % call the mex function that performs sparse tracking
            [xB, yB] = TrackFeaturesKLT(this.pyramidA, this.xA, this.yA, pyramidB, xB, yB, this.halfwin, this.thresh);

            % identify tracked and mistracked features
            bad = isnan(xB);
            good = ~bad;

            % select new features
            deficit = numel(good)-sum(good);
            [xBnew, yBnew] = selectFeatures(this, pyramidB{1}.gx, pyramidB{1}.gy, deficit);
            this.uniqueIndex(bad) = getUniqueIndices(this, deficit);
            xB(bad) = xBnew;
            yB(bad) = yBnew;
            
            % optionally display tracking results
            if(this.displayFeatures)
              if(isempty(this.figureHandle))
                this.figureHandle=figure;
              else
                figure(this.figureHandle);
                if(~isempty(this.plotHandle))
                  delete(this.plotHandle);
                end
              end
              imshow(pyramidB{1}.f, []);
              axis('image');
              hold('on');
              this.plotHandle=plot([this.yA(good);yB(good)],[this.xA(good);xB(good)],'r');
              drawnow;
            end
            
            % store both tracked and new features
            this.features(nodeB-this.nodeOffset).id = this.uniqueIndex;
            this.features(nodeB-this.nodeOffset).ray = this.camera.inverseProjection([yB; xB]-1, nodeB);

            % store the image pyramid and feature locations
            this.pyramidA = pyramidB;
            this.xA = xB;
            this.yA = yB;            
          end
          this.nodeA = nodeB;
        end
      end
    end
    
    % randomly select new image features
    function [x, y] = selectFeatures(this, gx, gy, num)
      kappa = computeCornerStrength(gx, gy, 0, this.cornerMethod);
      [x, y] = findPeaks(kappa, this.halfwin, num);
    end
    
    % get unique indices
    function id = getUniqueIndices(this, num)
      if(isempty(this.uniqueNext))
        this.uniqueNext = uint32(0);
      end
      if(num>0)
        a = this.uniqueNext;
        b = a + uint32(num-1);
        id = a:b;
        this.uniqueNext = b+uint32(1);
      else
        id = zeros(1,0,'uint32');
      end
    end
    
    % Prepare an image for processing
    %
    % Compute number of pyramid levels if this.firstTrack is true
    % Gets an image, normalizes it, and zero pads the bottom and right sides
    % Does not affect pixel coordinates
    function img = prepareImage(this, node)
      if(this.firstTrack)
        [numStrides, numSteps] = this.camera.getImageSize(node);
        pix = [double(numStrides)-2; double(numSteps)-1]/2;
        pix = [pix, pix+[1; 0]];
        ray = this.camera.inverseProjection(pix,node);
        angularSpacing = acos(dot(ray(:,1),ray(:,2)));
        maxPix = this.maxSearch/angularSpacing;
        this.numLevels = uint32(1+ceil(log2(maxPix/this.halfwin)));
      end
      img = this.camera.getImage(node);
      img = rgb2gray(img);
      multiple = 2^(this.numLevels-1);
      [M, N] = size(img);
      Mpad = multiple-mod(M, multiple);
      Npad = multiple-mod(N, multiple);
      if((Mpad>0)||(Npad>0))
        img(M+Mpad, N+Npad) = zeros(1, 1, class(img));
      end
      img = double(img)/255;
    end
  end
  
end
