classdef SparseTrackerKLT < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant=true,GetAccess=private)
    numLevels = 3;
    halfwin = 5;
    thresh = 0.98;
  end
  
  properties (GetAccess=private,SetAccess=private)
    camera
    indexA
    pyramidA
    xA
    yA
    offset
    features
    initialized
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
      
      this.initialized=false;
    end
  end
  
  methods (Abstract=false,Access=public,Static=false)
    function refresh(this)
      refresh(this.camera);
      
      % track features in new images
      if(~this.initialized)
        this.indexA = this.camera.first();
        imageA = this.prepareImage(this.indexA);
        this.pyramidA = buildPyramid(imageA, this.numLevels);
        kappa = computeCornerStrength(this.pyramidA{1}.gx, this.pyramidA{1}.gy, this.halfwin, 'Harris');
        peaksA = findPeaks(kappa, this.halfwin);
        [this.xA, this.yA] = find(peaksA);
        xB = this.xA;
        yB = this.yA;
        this.offset=this.indexA-uint32(1);
        this.features{1}.id=1:numel(this.xA);
        this.features{1}.ray=this.camera.inverseProjection([this.yA';this.xA']-1,this.indexA);
        this.initialized = true;
      end
      
      indexB=this.indexA+uint32(1);
      if(this.camera.last()>indexB)
        for indexB=(this.indexA+uint32(1)):this.camera.last()
          imageB = this.prepareImage(indexB);
          pyramidB = buildPyramid(imageB, this.numLevels);

          [xB, yB] = TrackFeaturesKLT(this.pyramidA, this.xA, this.yA, pyramidB, xB, yB, this.halfwin, this.thresh);

          good = find(~isnan(xB));
          this.xA = this.xA(good);
          this.yA = this.yA(good);
          xB = xB(good);
          yB = yB(good);

          % TODO: get more features
          this.features{indexB-this.offset}.id=good;
          this.features{indexB-this.offset}.ray=this.camera.inverseProjection([yB';xB']-1,indexB);

  %         figure(1);
  %         clf;
  %         imshow(this.pyramidA{1}.f);
  %         hold('on');
  %         axis('image');
  %         plot([this.yA,yB]', [this.xA,xB]', 'r');
  %         drawnow;

          this.pyramidA=pyramidB;
          this.xA=xB;
          this.yA=yB;
        end
        this.indexA=indexB;
      end
    end
    
    function flag=hasData(this)
      flag=hasData(this.camera);
    end
    
    function n=first(this)
      n=first(this.camera);
    end
    
    function n=last(this)
      n=last(this.camera);
    end
    
    function time=getTime(this,n)
      time=getTime(this.camera,n);
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
      num = numel(this.features{node-this.offset}.id);
    end
    
    function id = getFeatureID(this, node, localIndex)
      id = this.features{node-this.offset}.id(localIndex+uint32(1));
    end
    
    function ray = getFeatureRay(this, node, localIndex)
      ray = this.features{node-this.offset}.ray(:,localIndex+uint32(1));
    end
  end
  
  methods (Access=private)
    % get image, adjust levels, and zero pad without affecting pixel coordinates
    function img=prepareImage(this,index)
      img = this.camera.getImage(index);
      img = rgb2gray(img);
      multiple = 2^(this.numLevels-1);
      [M, N] = size(img);
      Mpad = multiple-mod(M, multiple);
      Npad = multiple-mod(N, multiple);
      if((Mpad>0)||(Npad>0))
        img(M+Mpad, N+Npad) = zeros(1,1,class(img));
      end
      img=double(img)/255;
    end
  end
  
end
