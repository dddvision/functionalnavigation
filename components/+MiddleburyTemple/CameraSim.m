classdef CameraSim < MiddleburyTemple.MiddleburyTempleConfig & hidi.Camera
  properties (Constant = true, GetAccess = private)
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
    fHorizontal
    fVertical
    cHorizontal
    cVertical
  end
  
  methods (Access = public, Static = true)
    function this = CameraSim(initialTime)
      this = this@hidi.Camera();
      numImages = numel(this.poseList);
      this.tn = initialTime+double(1:numImages-1)/this.fps;
      this.im = cell(numImages, 1);
      for n = 1:numImages
        this.im{n} = this.getMiddleburyTemple(n);
      end
      this.na = uint32(0);
      this.nb = this.na;
      this.M = uint32(size(this.im{1},1));
      this.N = uint32(size(this.im{1},2)); 
      this.refreshCount = uint32(0);
      
      filename = fullfile(fileparts(mfilename('fullpath')), this.dataSetName, [this.fileStub, '_par.txt']);
      fid = fopen(filename, 'rt');
      fgetl(fid); % discard first line
      format = [this.fileStub, '%04d.png %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'];
      str = fgetl(fid);
      data = sscanf(str, format);
      this.fHorizontal = data(2);
      this.fVertical = data(6);
      this.cHorizontal = data(4);
      this.cVertical = data(7);
      fclose(fid);
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
      ray(1, ray(1, :)<eps) = NaN; % behind the camera
      pix = [this.fHorizontal*ray(2, :)./ray(1, :)+this.cHorizontal;
        this.fVertical*ray(3, :)./ray(1, :)+this.cVertical];
      bad = (pix(1, :)<-0.5)|(pix(1, :)>(double(this.N)-0.5))|(pix(2, :)<-0.5)|(pix(2, :)>(double(this.M)-0.5));
      pix(1, bad) = NaN;
      pix(2, bad) = NaN;
    end
    
    function ray = inverseProjection(this, pix)
      assert(this.hasData());
      bad = (pix(1, :)<-0.5)|(pix(1, :)>(double(this.N)-0.5))|(pix(2, :)<-0.5)|(pix(2, :)>(double(this.M)-0.5));
      pix(1, bad) = NaN;
      pix(2, bad) = NaN;
      ray = [ones(1, size(pix, 2));
        (pix(1, :)-this.cHorizontal)/this.fHorizontal;
        (pix(2, :)-this.cVertical)/this.fVertical];
      den = sqrt(1+ray(2, :).*ray(2, :)+ray(3, :).*ray(3, :));
      ray(1, :) = ray(1, :)./den;
      ray(2, :) = ray(2, :)./den;
      ray(3, :) = ray(3, :)./den;
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
