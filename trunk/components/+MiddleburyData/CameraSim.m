classdef CameraSim < MiddleburyData.MiddleburyDataConfig & hidi.Camera
  
  properties (Constant = true, GetAccess = private)
    rho = 3740/(1390/2); % Reference: http://vision.middlebury.edu/stereo/data/scenes2005/
    layers = 'rgb';
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
      this = this@hidi.Camera();
      this.tn = initialTime+double(1:this.numImages-1)/this.fps;
      this.im = cell(this.numImages, 1);
      for n = 1:this.numImages
        this.im{n} = this.getMiddleburyArt(n-1);
      end
      this.na = uint32(0);
      this.nb = this.na;
      this.M = uint32(size(this.im{1},1));
      this.N = uint32(size(this.im{1},2)); 
      this.refreshCount = uint32(0);
    end
  end
  
  methods (Access = public)
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
      assert(all(n>=this.na));
      assert(all(n<=this.nb));
      time = zeros(size(n));
      time(:) = this.tn(n(:)-this.na+uint32(1));
    end
    
    function num = numSteps(this)
      num = this.M;
    end
    
    function num = numStrides(this)
      num = this.N;
    end
    
    function str = interpretLayers(this)
      str = this.layers;
    end
    
    function s = strideMin(this)
      assert(isa(this, 'hidi.Camera'));
      s = uint32(0);
    end
    
    function s = strideMax(this)
      s = this.numStrides()-uint32(1);
    end
    
    function s = stepMin(this)
      assert(isa(this, 'hidi.Camera'));
      s = uint32(0);
    end
    
    function s = stepMax(this)
      s = this.numSteps()-uint32(1);
    end
    
    function im = getImageUInt8(this, n)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      im = this.im{n-this.na+uint32(1)};
    end
    
    function im = getImageDouble(this, n)
      im = double(this.getImageUInt8(n))/255.0;
    end
    
    function pix = projection(this, ray)
      assert(this.hasData());
      m = double(this.M);
      n = double(this.N);
      coef = this.rho./ray(1,:);
      u1 = ((n-1)/(m-1))*coef.*ray(3, :);
      u2 = coef.*ray(2, :);
      pix = [(u2+1)*((n-1)/2); (u1+1)*((m-1)/2)];
    end
    
    function ray = inverseProjection(this, pix)
      assert(this.hasData());
      m = double(this.M);
      n = double(this.N);
      u1 = ((m-1)/(n-1))*(pix(2,:)*(2/(m-1))-1);
      u2 = pix(1, :)*(2/(n-1))-1;
      den = sqrt(u1.*u1+u2.*u2+this.rho*this.rho);
      ray = [this.rho./den; u2./den; u1./den];
    end
  end
  
  methods (Access = private)   
    function rgb = getMiddleburyArt(this, num)
      repository = 'http://vision.middlebury.edu/stereo/data/';
      cache = [fileparts(mfilename('fullpath')), '/'];
      subdir = [this.sceneYear, '/', this.fractionalSize, '/', this.scene, '/', this.illumination, '/', ...
        this.exposure, '/'];
      view = sprintf('view%d.png', num);
      fcache = fullfile(cache, subdir, view);
      dircache = [cache, subdir];
      if(~exist(dircache, 'file'))
        mkdir(dircache);
      end
      if(~exist(fcache, 'file'))
        url = [repository, subdir, view];
        if(this.verbose)
          fprintf('\ncaching: %s', url);
        end
        urlwrite(url, fcache);
      end
      rgb = imread(fcache);
    end
  end
  
end

