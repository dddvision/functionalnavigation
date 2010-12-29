classdef CameraSim < MiddleburyTemple.MiddleburyTempleConfig & antbed.Camera
  
  properties (Constant = true, GetAccess = private)
    rho = 3740/(1390/2); % Reference: http://vision.middlebury.edu/stereo/data/scenes2005/
    layers = 'rgb';
    frameDynamic = false;
    projectionDynamic = false;
    frame = [0; 0; 0; 1; 0; 0; 0];
  end
  
  properties (Access = private)
    tn
    na
    nb
    im
    M
    N
    refreshCount
  end
  
  methods (Access = public, Static = true)
    function this = CameraSim(initialTime)
      this = this@antbed.Camera(initialTime);
      numImages = numel(this.poseList);
      this.tn = tom.WorldTime(initialTime+double(1:numImages-1)/this.fps);
      this.im = cell(numImages, 1);
      for n = 1:numImages
        this.im{n} = getMiddleburyTemple(this, n);
      end
      this.na = uint32(0);
      this.nb = this.na;
      this.M = uint32(size(this.im{1},1));
      this.N = uint32(size(this.im{1},2)); 
      this.refreshCount = uint32(0);
    end
  end
  
  methods (Access = public, Static = false)
    function refresh(this, x)
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
    
    function num = numSteps(this, varargin)
      num = this.M;
    end
    
    function num = numStrides(this, varargin)
      num = this.N;
    end
    
    function str = interpretLayers(this, varargin)
      str = this.layers;
    end
    
    function im = getImage(this, n, varargin)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      im = this.im{n-this.na+uint32(1)};
    end

    function flag = isFrameDynamic(this, varargin)
      flag = this.frameDynamic;
    end
    
    function pose = getFrame(this, n, varargin)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      pose.p = this.frame(1:3);
      pose.q = this.frame(4:7);
      pose = tom.Pose(pose);
    end
    
    function flag = isProjectionDynamic(this, varargin)
      flag = this.projectionDynamic;
    end
    
    function pix = projection(this, ray, node, varargin)
      assert(this.hasData());
      assert(node>=this.na);
      assert(node<=this.nb);
      m = double(this.M);
      n = double(this.N);
      coef = this.rho./ray(1,:);
      u1 = ((n-1)/(m-1))*coef.*ray(3, :);
      u2 = coef.*ray(2, :);
      pix = [(u2+1)*((n-1)/2); (u1+1)*((m-1)/2)];
    end
    
    function ray = inverseProjection(this, pix, node, varargin)
      assert(this.hasData());
      assert(node>=this.na);
      assert(node<=this.nb);
      m = double(this.M);
      n = double(this.N);
      u1 = ((m-1)/(n-1))*(pix(2,:)*(2/(m-1))-1);
      u2 = pix(1, :)*(2/(n-1))-1;
      den = sqrt(u1.*u1+u2.*u2+this.rho*this.rho);
      ray = [this.rho./den; u2./den; u1./den];
    end
  end
  
  methods (Access = private)   
    function rgb = getMiddleburyTemple(this, num)
      cache = [fileparts(mfilename('fullpath')), '/', this.dataSetName];
      view = sprintf('%s%04d.png', this.dataSetName, this.poseList(num));
      fcache = fullfile(cache, view);
      rgb = imread(fcache);
    end
  end
  
end
