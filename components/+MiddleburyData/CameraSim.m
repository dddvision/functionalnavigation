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
    
    function str = interpretLayers(this)
      str = this.layers;
    end
    
    function num = numSteps(this)
      num = this.M;
    end
    
    function num = numStrides(this)
      num = this.N;
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
    
    function [strides, steps] = projection(this, c1, c2, c3)
      assert(this.hasData());
      m = double(this.M);
      n = double(this.N);
      coef = this.rho./c1;
      u1 = ((n-1.0)/(m-1.0))*coef.*c3;
      u2 = coef.*c2;
      strides = (u2+1.0)*((n-1.0)/2.0);
      steps = (u1+1.0)*((m-1.0)/2.0);
    end
    
    function [c1, c2, c3] = inverseProjection(this, strides, steps)
      assert(this.hasData());
      m = double(this.M);
      n = double(this.N);
      u1 = ((m-1.0)/(n-1.0))*(steps*(2.0/(m-1.0))-1.0);
      u2 = strides*(2.0/(n-1.0))-1.0;
      den = sqrt(u1.*u1+u2.*u2+this.rho*this.rho);
      c1 = this.rho./den;
      c2 = u2./den;
      c3 = u1./den;
    end
    
    function img = getImageUInt8(this, n, layer, img) %#ok input not used
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      img = this.im{n-this.na+uint32(1)};
      img = img(:, :, layer+1);
    end
    
    function img = getImageDouble(this, n, layer, img)
      img = double(this.getImageUInt8(n, layer, uint8(img*255.0)))/255.0;
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

