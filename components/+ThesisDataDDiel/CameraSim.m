classdef CameraSim < hidi.Camera
  properties (Constant = true, GetAccess = private)
    layers = 'rgb';
  end
  
  properties (SetAccess = private, GetAccess = private)
    na
    nb
    tn
    secondsPerRefresh
    refreshCount
    localCache
    imsize
    cameraType
  end
  
  methods (Access = public, Static = true)
    function this = CameraSim(initialTime, secondsPerRefresh, localCache)
      this = this@hidi.Camera();
      this.secondsPerRefresh = secondsPerRefresh;
      this.localCache = localCache;
      info = dir(fullfile(localCache,'/color*'));
      fnames = sortrows(cat(1, info(:).name));
      if(isempty(fnames))
        error('no images found in local cache');
      end
      S = load(fullfile(localCache, 'workspace.mat'), 'T_cam', 'CAMERA_TYPE', 'CAMERA_OFFSET');
      this.na = uint32(str2double(fnames(1, 6:11)));
      this.nb = this.na;
      this.tn = S.T_cam+initialTime; % same policy for all sensors
      this.cameraType = S.CAMERA_TYPE;
      %frameOffset = [S.CAMERA_OFFSET; 1; 0; 0; 0];
      imageA = imread([this.localCache, '/color', sprintf('%06d',this.na), '.png']);
      this.imsize = size(imageA);
      this.refreshCount = uint32(0);
    end
  end
    
  methods (Access = public)
    function refresh(this,x)
      assert(isa(x,'tom.Trajectory'));
      tMax = this.tn(1)+double(this.refreshCount)*this.secondsPerRefresh;
      nNext = this.nb+uint32(1);
      while((numel(this.tn)>nNext)&&(this.tn(nNext+1)<tMax))
        this.nb = nNext;
        nNext = this.nb+uint32(1);
      end
      this.refreshCount = this.refreshCount+uint32(1);  
    end
    
    function flag = hasData(this)      
      flag = this.refreshCount>uint32(0);
    end
    
    function n = first(this)
      assert(this.hasData());
      n = this.na;
    end

    function n = last(this)
      assert(this.hasData());
      n = this.nb;
    end
    
    function time = getTime(this, n)
      assert(this.hasData());
      assert(all(n>=this.na));
      assert(all(n<=this.nb));
      time = zeros(size(n));
      time(:) = this.tn(n(:)-this.na+uint32(1));
    end
    
    function str = interpretLayers(this)
      str = this.layers;
    end
    
    function num = numSteps(this)
      num = uint32(this.imsize(1));
    end

    function num = numStrides(this)
      num = uint32(this.imsize(2));
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
    
    function [strides, steps] = projection(this, forward, right, down)
      assert(this.hasData());
      switch(this.cameraType)
        case 2
          m = this.imsize(1);
          n = this.imsize(2);
          center = find(abs(1.0-forward)<eps);
          forward(center) = eps;
          scale = (2.0/pi)*acos(forward)./sqrt(1.0-forward.*forward);
          scale(center) = 0.0;
          behind = find(forward<=0.0);
          u1 = scale.*down;
          u2 = scale.*right;
          u1(behind) = nan;
          u2(behind) = nan;
          strides = (u2+1.0)*((n-1.0)/2.0);
          steps = (u1+1.0)*((m-1)/2.0);
        case 4
          thmax = 1.570796;
          ic = 254.5;
          jc = 317.0;
          a1 = 153.170245942;
          a2 = -0.083878888;
          b1 = 0.149954284;
          b2 = -0.06062850;
          c1 = -down;
          c2 = forward;
          c3 = -right;
          c1(c1<cos(thmax)) = nan;
          th = acos(c1);
          th2 = th.*th;
          r = (a1*th+a2*th2)./(1.0+b1*th+b2*th2);
          mag = sqrt(c2.*c2+c3.*c3);
          mag(abs(mag)<eps) = eps;
          strides = jc+r.*c2./mag-1.0;
          steps = ic+r.*c3./mag-1.0;
        otherwise
          error('unrecognized camera type');
      end   
      
    end
    
    function [c1, c2, c3] = inverseProjection(this, strides, steps)
      assert(this.hasData());
      switch(this.cameraType)
        case 2
          m = this.imsize(1);
          n = this.imsize(2);
          down = (steps+1.0)*2.0/(n-1.0)+(m+1.0)/(1.0-n);
          right = (strides+1.0)*(2.0/(n-1.0))+(1.0+n)/(1.0-n);
          r = sqrt(down.*down+right.*right);
          a = (r>1.0);
          b = (r==0.0);
          ca = ((r~=0.0)&(right<0.0));
          cb = ((r~=0.0)&(right>=0.0));
          phi = zeros(size(b));
          phi(ca) = pi-asin(down(ca)./r(ca));
          phi(cb) = asin(down(cb)./r(cb));
          theta = r*(pi/2.0);
          cp = cos(phi);
          ct = cos(theta);
          sp = sin(phi);
          st = sin(theta);
          c1 = ct;
          c2 = cp.*st;
          c3 = sp.*st;
          c1(a) = nan;
          c2(a) = nan;
          c3(a) = nan;
        case 4
          thmax = 1.570796;
          ic = 254.5;
          jc = 317.0;
          a1 = 153.170245942;
          a2 = -0.083878888;
          b1 = 0.149954284;
          b2 = -0.06062850;
          i = steps+1.0;
          j = strides+1.0;
          j = j-jc;
          i = i-ic;
          r = sqrt(i.*i+j.*j);
          rmax = (a1*thmax+a2*thmax.*thmax)./(1.0+b1*thmax+b2*thmax.*thmax);
          r(r>rmax) = nan;
          th = (sqrt(a1*a1-2.0*a1*b1*r+(4.0*a2+(b1*b1-4.0*b2)*r).*r)-a1+b1*r)./(2.0*(a2-b2*r));
          c1 = -cos(th);
          r(r<eps) = 1.0;
          c2 = sin(th).*j./r;
          c3 = -sin(th).*i./r;
        otherwise
          error('unrecognized camera type');
      end
    end
      
    function img = getImageUInt8(this, n, layer, img) %#ok input not used
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      img = imread([this.localCache, '/color', sprintf('%06d',n), '.png']);
      img = img(:, :, layer+1);
    end

    function img = getImageDouble(this, n, layer, img)
      img = double(this.getImageUInt8(n, layer, uint8(img*255.0)))/255.0;
    end
  end
end
