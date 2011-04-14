classdef SparseTrackerSURF < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant = true, GetAccess = private)
    openSurfOptions = struct('tresh',  0.00005,...
              'init_sample', 1,...
              'octaves',  3);
  end
  
  properties (GetAccess = private, SetAccess = private)
    camera
  end
  
  methods (Access = public, Static = true)
    function this = SparseTrackerSURF(initialTime, camera)
      this = this@FastPBM.SparseTracker(initialTime);
      this.camera = camera;
    end
  end
  
  methods (Abstract = false, Access = public, Static = false)
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
    
    function flag = isFrameDynamic(this)
      flag = this.camera.isFrameDynamic();
    end
    
    function pose = getFrame(this, node)
      pose = this.camera.getFrame(node);
    end
    
    function [rayA, rayB] = findMatches(this, nodeA, nodeB)
      dataA = FastPBM.nodeCache(nodeA, this);
      dataB = FastPBM.nodeCache(nodeB, this);
      dataAB = FastPBM.edgeCache(nodeA, nodeB, this);
      rayA = dataA.ray(:, dataAB.matchA+uint32(1));
      rayB = dataB.ray(:, dataAB.matchB+uint32(1));
    end
  
    function data = processNode(this, node)
      img = this.prepareImage(node);
      key = OpenSurf(img, this.openSurfOptions);
      ray = this.camera.inverseProjection([[key.x];[key.y]]-1, node);
      data = struct('key', key, 'ray', ray);
    end

    function data = processEdge(this, nodeA, nodeB)
      dataA = FastPBM.nodeCache(nodeA, this);
      dataB = FastPBM.nodeCache(nodeB, this);
      keyA = dataA.key;
      keyB = dataB.key;
      [iA, iB] = MatchSurf(keyA, keyB);
      data = struct('matchA', uint32(iA-1), 'matchB', uint32(iB-1));

      % optionally display tracking results
      if(this.displayFeatures)
        imageA = this.prepareImage(nodeA);
        imageB = this.prepareImage(nodeB);
        pixA = [[keyA(iA).x];[keyA(iA).y]]-1;
        pixB = [[keyB(iB).x];[keyB(iB).y]]-1;
        FastPBM.displayFeatures(imageA, imageB, pixA, pixB);
      end
    end
    
    % Prepare an image for processing
    function img = prepareImage(this, node)
      img = this.camera.getImage(node);
      switch(this.camera.interpretLayers())
        case {'rgb', 'rgbi'}
          img = double(rgb2gray(img(:, :, 1:3)))/255;
        case {'hsv', 'hsvi'}
          img = double(img(:, :, 3))/255;
        otherwise
          img = double(img)/255;
      end
    end
  end
end
