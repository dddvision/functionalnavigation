classdef MacCam < XBOXKinect.XBOXKinectConfig & antbed.Camera
  
  properties (Constant = true, GetAccess = private)
    na = uint32(1);
    steps = uint32(120);
    strides = uint32(160);
    layers = 'rgb';
    frameDynamic = false;
    projectionDynamic = false;
    clockBase = [1980, 1, 6, 0, 0, 0];
    defaultRate = 1/30;
    fileFormat = '%05d.png';
    vlcErrorText = 'MacBook camera depends on VLC Media Player for OS X';
    timeOutText = 'Timeout while waiting for camera initialization';
  end
  
  properties (Access = private)
    focal
    nb
    rate
    ready
    initialTime
    refTime
    timeZoneOffset 
  end
  
  methods (Access = public)
    function this = MacCam(initialTime)
      this = this@antbed.Camera(initialTime);
      if(this.verbose)
        fprintf('\nInitializing %s', class(this));
      end
      
      this.focal = double(this.strides)*cot(this.cameraFieldOfView/2);
      
      if(this.overwrite)
        calendar = java.util.GregorianCalendar;
        zone = calendar.getTimeZone;
        this.timeZoneOffset = (zone.getRawOffset+zone.getDSTSavings)/1000;

        if(~exist(this.localCache, 'dir'))
          mkdir(this.localCache);
        end
        delete(fullfile(this.localCache, '*.png'));
        delete(fullfile(this.localCache, '*.swp'));

        if(~exist(this.vlcPath, 'file'))
          error(this.vlcErrorText);
        end
        startcmd = [sprintf('%s qtcapture:// ', this.vlcPath), ...
          '--vout=dummy --aout=dummy --video-filter=scene --scene-format=png --scene-prefix="" ', ...
          sprintf('--scene-width=%d --scene-height=%d ', this.strides, this.steps), ...
          sprintf('--scene-ratio=%d --scene-path=%s ', this.cameraIncrement, this.localCache), ...
          '2> /dev/null &'];
        unix(startcmd);

        this.ready = false;
        t0 = clock;
        t1 = clock;
        while(etime(t1, t0)<this.timeOut)
          if(isValid(this, uint32(1)))
            t1 = clock;
            this.ready = true;
            break;
          end
          t1 = clock;
        end
        if(~this.ready)
          error(this.timeOutText);
        end
        this.ready = false;
        t2 = clock;
        while(etime(t2, t1)<(this.timeOut+0.2*this.cameraIncrement))
          if(isValid(this, uint32(2)))
            t2 = clock;
            this.ready = true;
            break;
          end
          t2 = clock;
        end
        if(~this.ready)
          error(this.timeOutText);
        end
        this.rate = etime(t2, t1);
        this.initialTime = etime(t1, this.clockBase)-this.rate;
        this.refTime = t1;
        this.nb = uint32(2);
      else
        this.initialTime = initialTime;
        this.rate = this.defaultRate;
        this.ready = false;
        this.nb = this.na;
        while(this.isValid(this.nb))
          this.nb = this.nb+uint32(1);
          this.ready = true;
        end
      end
    end

    function refresh(this, x)
      assert(isa(x, 'tom.Trajectory'));
      if(this.overwrite)
        kRef = this.nb;
        while(isValid(this, this.nb+uint32(1)))
          time = clock;
          this.nb = this.nb+uint32(1);
        end
        if(this.nb>kRef)
          numImages = double(this.nb-this.na+uint32(1)); % adds one to account for behavior of isValid
          this.rate = etime(time, this.refTime)/numImages; 
        end
      end
    end
    
    function flag = hasData(this)
      flag = this.ready;
    end
    
    function na = first(this)
      na = this.na;
    end

    function nb = last(this)
      nb = this.nb;
    end
    
    function time = getTime(this, n)
      assert(n>=this.na);
      assert(n<=this.nb);
      if(this.overwrite)
        time = tom.WorldTime(this.initialTime+this.rate*double(n-this.na)-this.timeZoneOffset);
      else
        time = tom.WorldTime(this.initialTime+this.rate*double(n-this.na));
      end
    end
    
    function num = numSteps(this, varargin)
      num = this.steps;
    end
    
    function num = numStrides(this, varargin)
      num = this.strides;
    end
    
    function str = interpretLayers(this, varargin)
      str = this.layers;
    end
    
    function im = getImage(this, n, varargin)
      assert(n>=this.na);
      assert(n<=this.nb);
      num = this.na+this.cameraIncrement*n;
      im = imread(fullfile(this.localCache, sprintf(this.fileFormat, num)));
    end
    
    function flag = isFrameDynamic(this, varargin)
      flag = this.frameDynamic;
    end
    
    function pose = getFrame(this, n, varargin)
      assert(n>=this.na);
      assert(n<=this.nb);
      pose.p = this.cameraPositionOffset;
      pose.q = this.cameraRotationOffset;
      pose = tom.Pose(pose);
    end
        
    function flag = isProjectionDynamic(this, varargin)
      flag = this.projectionDynamic;
    end

    function pix = projection(this, ray, varargin)
      c1 = ray(1, :);
      c2 = ray(2, :);
      c3 = ray(3, :);
      m = double(this.steps);
      n = double(this.strides);
      mc = (m-1)/2;
      nc = (n-1)/2;
      c1((c1<=0)|(c1>1)) = NaN;
      r = this.focal*sqrt(1-c1.*c1)./c1; % r = f*tan(acos(c1))
      theta = atan2(c3, c2);
      pm = r.*sin(theta)+mc;
      pn = r.*cos(theta)+nc;
      outside = ((-0.5>pm)|(-0.5>pn)|(pn>(n-0.5))|(pm>(m-0.5)));
      pm(outside) = NaN;
      pn(outside) = NaN;
      pix = [pn; pm];
    end
    
    function ray = inverseProjection(this, pix, varargin)
      m = double(this.steps);
      n = double(this.strides);
      mc = (m-1)/2;
      nc = (n-1)/2;
      pm = pix(2, :);
      pn = pix(1, :);
      outside = ((-0.5>pm)|(-0.5>pn)|(pn>(n-0.5))|(pm>(m-0.5)));
      pm(outside) = NaN;
      pn(outside) = NaN;
      pm = pm-mc;
      pn = pn-nc;
      r = sqrt(pm.*pm+pn.*pn);
      alpha = atan(r/this.focal);
      theta = atan2(pm, pn);
      c1 = cos(alpha);
      c2 = sin(alpha).*cos(theta);
      c3 = sin(alpha).*sin(theta);
      ray = [c1; c2; c3];
    end
    
    % Stops the image capture process
    function delete(this)
      if(this.overwrite)
        [base, name, ext] = fileparts(this.vlcPath);
        unix(['killall -9 ', name, ext]);
      end
    end
  end
  
  methods (Access = private)
    % checks for the next image being written to validate the current image
    function flag = isValid(this, n)
      num = this.na+this.cameraIncrement*(n+1); % adds one
      fname = fullfile(this.localCache, sprintf(this.fileFormat, num));
      flag = exist(fname, 'file');
    end
  end
end
