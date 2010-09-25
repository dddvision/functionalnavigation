classdef SparseTrackerKLT < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant=true,GetAccess=private)
    numLevels = 3;
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
    firstRefresh
  end
  
  methods (Access=public,Static=true)
    function this=SparseTrackerKLT(camera)
      this.camera=camera;
      
      if(~exist('mexTrackFeaturesKLT','file'))
        userDirectory=pwd;
        cd(fullfile(fileparts(mfilename('fullpath')),'private'));
        try
          mex('mexTrackFeaturesKLT.cpp');
        catch err
          cd(userDirectory);
          error(err.message);
        end
        cd(userDirectory);
      end
      
      this.firstRefresh=true;
    end
  end
  
  methods (Abstract=false,Access=public,Static=false)
    function refresh(this)
      refresh(this.camera);
      
      % find features in first image
      if(this.firstRefresh)
        this.nodeA = this.camera.first();
        this.nodeOffset = this.nodeA-uint32(1);
        this.pyramidA = buildPyramid(this.prepareImage(this.nodeA), this.numLevels);
        [this.xA, this.yA] = selectFeatures(this, this.pyramidA{1}.gx, this.pyramidA{1}.gy, this.maxFeatures);
        this.uniqueIndex = getUniqueIndices(this, numel(this.xA));
        this.features{1}.id = this.uniqueIndex;
        this.features{1}.ray = this.camera.inverseProjection([this.yA;this.xA]-1, this.nodeA);
      end
      
      % track features in new images
      nodeB=this.nodeA+uint32(1);
      if(this.camera.last()>nodeB)
        xB = this.xA;
        yB = this.yA;
        for nodeB = nodeB:this.camera.last()
          pyramidB = buildPyramid(this.prepareImage(nodeB), this.numLevels);

          [xB, yB] = TrackFeaturesKLT(this.pyramidA, this.xA, this.yA, pyramidB, xB, yB, this.halfwin, this.thresh);

          % identify tracked and mistracked features
          bad = isnan(xB);
          good = ~bad;
          numGood = sum(good);
          
          if(this.firstRefresh)
            this.features{1}.id = this.features{1}.id(good);
            this.features{1}.ray = this.features{1}.ray(:, good);
            this.firstRefresh = false;
          end

          this.features{nodeB-this.nodeOffset}.id=this.uniqueIndex(good);
          this.features{nodeB-this.nodeOffset}.ray=this.camera.inverseProjection([yB(good); xB(good)]-1, nodeB);
          
          deficit = numel(good)-numGood;
          [xBnew, yBnew] = selectFeatures(this, pyramidB{1}.gx, pyramidB{1}.gy, deficit);
          this.uniqueIndex(bad) = getUniqueIndices(this, deficit);
          xB(bad) = xBnew;
          yB(bad) = yBnew;
          
          this.pyramidA = pyramidB;
          this.xA = xB;
          this.yA = yB;
        end
        this.nodeA = nodeB;
      end
    end
    
    function flag = hasData(this)
      flag = hasData(this.camera);
    end
    
    function n = first(this)
      n = first(this.camera);
    end
    
    function n = last(this)
      n = last(this.camera);
    end
    
    function time = getTime(this, n)
      time = getTime(this.camera, n);
    end

    function refreshWithPrediction(this, x)
      assert(isa(x,'Trajectory'));
      refresh(this);
    end
    
    function flag = isFrameDynamic(this)
      flag = isFrameDynamic(this.camera);
    end    
    
    function pose = getFrame(this, node)
      pose = getFrame(this.camera, node);
    end
    
    function num = numFeatures(this, node)
      num = numel(this.features{node-this.nodeOffset}.id);
    end
    
    function id = getFeatureID(this, node, localIndex)
      id = this.features{node-this.nodeOffset}.id(localIndex+uint32(1));
    end
    
    function ray = getFeatureRay(this, node, localIndex)
      ray = this.features{node-this.nodeOffset}.ray(:, localIndex+uint32(1));
    end
  end
  
  methods (Access=private)
    % randomly select new image features
    function [x, y] = selectFeatures(this, gx, gy, num)
      kappa = computeCornerStrength(gx, gy, 0, this.cornerMethod);
      [x, y] = findPeaks(kappa, this.halfwin, num);
    end
    
    % get unique indices
    function id = getUniqueIndices(this,num)
      if(isempty(this.uniqueNext))
        this.uniqueNext = uint32(0);
      end
      a = this.uniqueNext;
      b = a + uint32(num-1);
      id = a:b;
      this.uniqueNext = b+uint32(1);
    end
    
    % get image, adjust levels, and zero pad without affecting pixel coordinates
    function img = prepareImage(this,index)
      img = this.camera.getImage(index);
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
