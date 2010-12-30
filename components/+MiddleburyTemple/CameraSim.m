classdef CameraSim < MiddleburyTemple.MiddleburyTempleConfig & antbed.Camera
  
  properties (Constant = true, GetAccess = private)
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
    fHorizontal
    fVertical
    cHorizontal
    cVertical
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
      ray(1, ray(1, :)<eps) = NaN; % behind the camera
      pix = [this.fHorizontal*ray(2, :)./ray(1, :)+this.cHorizontal;
        this.fVertical*ray(3, :)./ray(1, :)+this.cVertical];
      bad = (pix(1, :)<-0.5)|(pix(1, :)>(double(this.N)-0.5))|(pix(2, :)<-0.5)|(pix(2, :)>(double(this.M)-0.5));
      pix(1, bad) = NaN;
      pix(2, bad) = NaN;
    end
    
    function ray = inverseProjection(this, pix, node, varargin)
      assert(this.hasData());
      assert(node>=this.na);
      assert(node<=this.nb);
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
