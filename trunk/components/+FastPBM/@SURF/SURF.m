classdef SURF < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant = true, GetAccess = private)
    openSurfOptions = struct(...
      'tresh',  0.00005, ...
      'init_sample', 1, ...
      'octaves',  3);
  end
  
  properties (GetAccess = private, SetAccess = private)
    camera
  end
  
  methods (Access = public, Static = true)
    function this = SURF(initialTime, camera)
      this = this@FastPBM.SparseTracker(initialTime);
      this.camera = camera;
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
      dataA = FastPBM.nodeCache(nodeA, this);
      dataB = FastPBM.nodeCache(nodeB, this);
      dataAB = FastPBM.edgeCache(nodeA, nodeB, this);
      rayA = dataA.ray(:, dataAB.matchA+uint32(1));
      rayB = dataB.ray(:, dataAB.matchB+uint32(1));
    end
  
    function data = processNode(this, node)
      img = this.prepareImage(node);
      key = OpenSurf(img, this.openSurfOptions);
      ray = this.camera.inverseProjection([[key.x];[key.y]]-1);
      data = struct('key', key, 'ray', ray);
    end

    function data = processEdge(this, nodeA, nodeB)
      dataA = FastPBM.nodeCache(nodeA, this);
      dataB = FastPBM.nodeCache(nodeB, this);
      keyA = dataA.key;
      keyB = dataB.key;
      [iA, iB] = matchSURF(keyA, keyB);
      data = struct('matchA', uint32(iA-1), 'matchB', uint32(iB-1));
    end
    
    % Prepare an image for processing
    function img = prepareImage(this, node)
      img = this.camera.getImageDouble(node, uint32(0), uint8(0)); % process red only for speed
    end
  end
end

function [a, b] = matchSURF(keyA, keyB)
  thresh = 0.02;

  LA = [keyA.laplacian]';
  LB = [keyB.laplacian]';
  
  mapA0 = find(~LA);
  mapB0 = find(~LB);
  
  mapA1 = find(LA);
  mapB1 = find(LB);
  
  A0 = [keyA(mapA0).descriptor];
  B0 = [keyB(mapB0).descriptor];

  A1 = [keyA(mapA1).descriptor];
  B1 = [keyB(mapB1).descriptor];
  
  [a0, b0] = computeDistanceSURF(A0, B0, thresh);
  [a1, b1] = computeDistanceSURF(A1, B1, thresh);
  
  a = [mapA0(a0); mapA1(a1)];
  b = [mapB0(b0); mapB1(b1)];
end

function [a, b] = computeDistanceSURF(A, B, thresh)
  nA = size(A, 2);
  nB = size(B, 2);
  D = zeros(nA, nB);
  for a = 1:nA
    d = bsxfun(@minus, B, A(:, a));
    D(a, :) = sum(d.*d);
  end
  [a, b] = find((D<thresh)&bsxfun(@eq, D, min(D, [], 1))&bsxfun(@eq, D, min(D, [], 2)));
end
