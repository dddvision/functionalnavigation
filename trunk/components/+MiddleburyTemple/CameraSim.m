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
      c1(c1<eps) = nan; % behind the camera
      strides = this.fHorizontal*c2./c1+this.cHorizontal;
      steps = this.fVertical*c3./c1+this.cVertical;
      bad = (strides(:)<-0.5)|(strides(:)>(double(this.N)-0.5))|(steps(:)<-0.5)|(steps(:)>(double(this.M)-0.5));
      strides(bad) = nan;
      steps(bad) = nan;
    end
    
    function [c1, c2, c3] = inverseProjection(this, strides, steps)
      assert(this.hasData());
      bad = (strides(:)<-0.5)|(strides(:)>(double(this.N)-0.5))|(steps(:)<-0.5)|(steps(:)>(double(this.M)-0.5));
      strides(bad) = nan;
      steps(bad) = nan;
      c1 = ones(size(strides));
      c2 = (strides-this.cHorizontal)./this.fHorizontal;
      c3 = (steps-this.cVertical)./this.fVertical;
      den = sqrt(1+c2.*c2+c3.*c3);
      c1 = c1./den;
      c2 = c2./den;
      c3 = c3./den;
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
    function rgb = getMiddleburyTemple(this, num)
      cache = [fileparts(mfilename('fullpath')), '/', this.dataSetName];
      view = sprintf('%s%04d.png', this.dataSetName, this.poseList(num));
      fcache = fullfile(cache, view);
      rgb = imread(fcache);
    end
  end
end
