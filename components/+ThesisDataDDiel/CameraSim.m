classdef CameraSim < antbed.Camera
  
  properties (Constant = true, GetAccess = private)
    layers = 'rgb';
    frameDynamic = false;
    projectionDynamic = false;
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
    frameOffset
  end
  
  methods (Access = public, Static = true)
    function this = CameraSim(initialTime, secondsPerRefresh, localCache)
      this = this@antbed.Camera(initialTime);
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
      this.tn = tom.WorldTime(S.T_cam+initialTime); % same policy for all sensors
      this.cameraType = S.CAMERA_TYPE;
      this.frameOffset = [S.CAMERA_OFFSET; 1; 0; 0; 0];
      imageA = imread([this.localCache, '/color', sprintf('%06d',this.na), '.png']);
      this.imsize = size(imageA);
      this.refreshCount = uint32(0);
    end
  end
    
  methods (Access = public, Static = false)
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
      assert(n>=this.na);
      assert(n<=this.nb);
      time = this.tn(n-this.na+uint32(1));
    end
    
    function num = numSteps(this,varargin)
      num = uint32(this.imsize(1));
    end

    function num = numStrides(this,varargin)
      num = uint32(this.imsize(2));
    end
    
    function str = interpretLayers(this, varargin)
      str = this.layers;
    end
    
    function im = getImage(this, n, varargin)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      im = imread([this.localCache, '/color', sprintf('%06d',n), '.png']);
    end
    
    function flag = isFrameDynamic(this, varargin)
      flag = this.frameDynamic;
    end
    
    function pose = getFrame(this, n, varargin)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      pose.p = this.frameOffset(1:3);
      pose.q = this.frameOffset(4:7);
      pose = tom.Pose(pose);
    end
        
    function flag = isProjectionDynamic(this, varargin)
      flag = this.projectionDynamic;
    end

    function pix = projection(this, ray, node, varargin)
      assert(this.hasData());
      assert(node>=this.na);
      assert(node<=this.nb);
      switch(this.cameraType)
        case 2
          m = this.imsize(1);
          n = this.imsize(2);
          c1 = ray(1, :);
          c2 = ray(2, :);
          c3 = ray(3, :);
          center = find(abs(1-c1)<eps);
          c1(center) = eps;
          scale = (2/pi)*acos(c1)./sqrt(1-c1.*c1);
          scale(center) = 0;
          behind = find(c1(:)<=0);
          u1 = scale.*c3;
          u2 = scale.*c2;
          u1(behind) = NaN;
          u2(behind) = NaN;
          pix = [(u2+1)*((n-1)/2); (u1+1)*((m-1)/2)];
        case 4
          thmax = 1.570796;
          ic = 254.5;
          jc = 317.0;
          a1 = 153.170245942;
          a2 = -0.083878888;
          b1 = 0.149954284;
          b2 = -0.06062850;
          c1 = -ray(3, :);
          c2 = ray(1, :);
          c3 = -ray(2, :);
          c1(c1<cos(thmax)) = NaN;
          th = acos(c1);
          th2 = th.*th;
          r = (a1*th+a2*th2)./(1+b1*th+b2*th2);
          mag = sqrt(c2.*c2+c3.*c3);
          mag(abs(mag)<eps) = eps;
          pix = [jc+r.*c2./mag-1; ic+r.*c3./mag-1];
        otherwise
          error('unrecognized camera type');
      end   
      
    end
    
    function ray = inverseProjection(this, pix, node, varargin)
      assert(this.hasData());
      assert(node>=this.na);
      assert(node<=this.nb);
      switch(this.cameraType)
        case 2
          m = this.imsize(1);
          n = this.imsize(2);
          down = (pix(2, :)+1)*2/(n-1)+(m+1)/(1-n);
          right = (pix(1, :)+1)*(2/(n-1))+(1+n)/(1-n);
          r = sqrt(down.*down+right.*right);
          a = (r>1);
          b = (r==0);
          ca = ((r~=0)&(right<0));
          cb = ((r~=0)&(right>=0));
          phi = zeros(size(b));
          phi(ca) = pi-asin(down(ca)./r(ca));
          phi(cb) = asin(down(cb)./r(cb));
          theta = r*(pi/2);
          cp = cos(phi);
          ct = cos(theta);
          sp = sin(phi);
          st = sin(theta);
          c1 = ct;
          c2 = cp.*st;
          c3 = sp.*st;
          c1(a) = NaN;
          c2(a) = NaN;
          c3(a) = NaN;
          ray = cat(1, c1, c2, c3);
        case 4
          thmax = 1.570796;
          ic = 254.5;
          jc = 317.0;
          a1 = 153.170245942;
          a2 = -0.083878888;
          b1 = 0.149954284;
          b2 = -0.06062850;
          i = pix(2, :)+1;
          j = pix(1, :)+1;
          j = j-jc;
          i = i-ic;
          r = sqrt(i.*i+j.*j);
          rmax = (a1*thmax+a2*thmax^2)./(1+b1*thmax+b2*thmax^2);
          r(r>rmax) = NaN;
          th = (sqrt(a1^2-2*a1*b1*r+(4*a2+(b1^2-4*b2)*r).*r)-a1+b1*r)./(2*(a2-b2*r));
          c1 = cos(th);
          r(r<eps) = 1;
          c2 = sin(th).*j./r;
          c3 = sin(th).*i./r;
          ray = cat(1, c2, -c3, -c1);
        otherwise
          error('unrecognized camera type');
      end      
    end
  end
  
end
