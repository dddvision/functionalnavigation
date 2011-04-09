classdef SparseTrackerSURF < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant = true, GetAccess = private)
    openSurfOptions = struct('tresh',  0.00005,...
              'init_sample', 1,...
              'octaves',  3);
  end
  
  properties (GetAccess = private, SetAccess = private)
    camera
    mask
    nodeA
    nodePrevious
    xA
    yA
    features
    uniqueIndex
    uniqueNext
    firstTrack
    figureHandle
    plotHandle
  end
  
  methods (Access = public, Static = true)
    function this = SparseTrackerSURF(initialTime, camera)
      this = this@FastPBM.SparseTracker(initialTime);
      this.camera = camera;
      this.firstTrack = true;
      this.track();
    end
  end
  
  methods (Abstract = false, Access = public, Static = false)
    function refresh(this, x)
      this.camera.refresh(x);
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
      num = numel(this.features(node-this.nodeA+uint32(1)).id);
    end
    
    function id = getFeatureID(this, node, localIndex)
      id = this.features(node-this.nodeA+uint32(1)).id(localIndex+uint32(1));
    end
    
    function ray = getFeatureRay(this, node, localIndex)
      ray = this.features(node-this.nodeA+uint32(1)).ray(:, localIndex+uint32(1));
    end
  end
  
  methods (Access=private)
    % perform tracking
    function track(this)
      
      % only attempt to track if the camera has data
      if(this.camera.hasData())
        if(this.firstTrack)
          this.nodeA = this.camera.first();
          this.nodePrevious = this.nodeA;
        end
        
        % if there are any new images
        nodeLast = this.camera.last();
        nodeB = this.nodePrevious+uint32(1);
        if(nodeLast>=nodeB)
          
          % process all new images
          for nodeB = nodeB:nodeLast
            
            imageA = this.prepareImage(this.nodeA);
            imageB = this.prepareImage(nodeB);
            
            keyA = OpenSurf(imageA, this.openSurfOptions);
            keyB = OpenSurf(imageB, this.openSurfOptions);
            [a, b] = MatchSurf(keyA, keyB);
            this.xA = [keyA(a).y];
            this.yA = [keyA(a).x];
            xB = [keyB(b).y];
            yB = [keyB(b).x];
            
            % optionally display tracking results
            if(this.displayFeatures)
              if(isempty(this.figureHandle))
                this.figureHandle = figure;
              else
                figure(this.figureHandle);
                if(~isempty(this.plotHandle))
                  delete(this.plotHandle);
                end
              end
              imshow(cat(3, zeros(size(imageA)), 0.5+(imageA-imageB)/2, 0.5+(imageB-imageA)));
              axis('image');
              hold('on');
              this.plotHandle = line([this.yA; yB], [this.xA; xB], 'Color', 'r');
              drawnow;
            end
            
            % store both tracked and new features
            this.features(nodeB-this.nodeA).id = this.uniqueIndex;
            this.features(nodeB-this.nodeA).ray = this.camera.inverseProjection([this.yA;this.xA]-1, this.nodeA);
            
            this.features(nodeB-this.nodeA+uint32(1)).id = this.uniqueIndex;
            this.features(nodeB-this.nodeA+uint32(1)).ray = this.camera.inverseProjection([yB; xB]-1, nodeB);
          end
          this.nodePrevious = nodeB;
        end
      end
    end
    
    % get unique indices
    function id = getUniqueIndices(this, num)
      if(isempty(this.uniqueNext))
        this.uniqueNext = uint32(0);
      end
      if(num>0)
        a = this.uniqueNext;
        b = a+uint32(num-1);
        id = a:b;
        this.uniqueNext = b+uint32(1);
      else
        id = zeros(1, 0, 'uint32');
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