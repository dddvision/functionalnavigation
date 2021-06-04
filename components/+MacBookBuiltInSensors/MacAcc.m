classdef MacAcc < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & hidi.AccelerometerArray
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  
  properties (Constant = true, GetAccess = private)
    na = uint32(0);
    nAxes = uint32(3);
    smsLib = 'smslib.m';
    smsCode = 'smsutil.m';
    smsApp = 'smsapp';
    smsLog = 'sms.csv';
    compilerFlags = '-arch x86_64 -ObjC -framework Foundation -framework IOKit -Wall';
    smsFlags = '-i0 -c0 -atxyz -s44'; % 40 bytes per line
    lineSkip = 40;
    clockBase = [1980, 1, 6, 0, 0, 0];
    timeOutText = 'Timeout while waiting for accelerometer initialization';
    indexErrorText = 'Accelerometer axis index is out of range';
    
    % ADXL103 accelerometer model
    biasTurnOn = (9.8E-3)*25; % meters/sec^2
    biasSteadyState = (9.8E-3)*3.3; % meters/sec^2
    biasDecay = 60; % sec
    scaleTurnOn = (1E-6)*3000; % unitless
    scaleSteadyState = (1E-6)*3000; % unitless
    scaleDecay = 60; % sec
    randomWalk = (1/sqrt(3600))*0.09; % meters/sec/sqrt(sec)    
  end
  
  properties (Access = private)
    fid
    nb
    ready
    initialTime
    zoneOffset
  end
  
  methods (Access = public)
    function this = MacAcc()
      this = this@hidi.AccelerometerArray();
      if(this.verbose)
        fprintf('\nInitializing %s', class(this));
      end
      
      % store time zone offset
      calendar = java.util.GregorianCalendar;
      zone = calendar.getTimeZone;
      this.zoneOffset = (zone.getRawOffset+zone.getDSTSavings)/1000;
      
      thisPath = fileparts(mfilename('fullpath'));
      smsLibPath = fullfile(thisPath, this.smsLib);
      smsCodePath = fullfile(thisPath, this.smsCode);
      smsAppPath = fullfile(this.localCache, this.smsApp);
      smsLogPath = fullfile(this.localCache, this.smsLog);
      
      if(~exist(this.localCache, 'dir'))
        mkdir(this.localCache);
      end
      delete([smsLogPath, '*']);
      
      if(~exist(smsAppPath, 'file'))
        unix(sprintf('g++ %s %s %s -o %s', this.compilerFlags, smsLibPath, smsCodePath, smsAppPath));
      end
      unix(sprintf('%s %s > %s &', smsAppPath, this.smsFlags, smsLogPath));
      
      % ensure that sms log file exists
      this.ready = false;
      t0 = clock;
      t1 = clock;
      while(etime(t1, t0)<this.timeOut)
        if(exist(smsLogPath, 'file'))
          t1 = clock;
          this.ready = true;
          break;
        end
        t1 = clock;
      end
      if(~this.ready)
        error(this.timeOutText);
      end
      this.initialTime = etime(t1, this.clockBase);
      this.fid = fopen(smsLogPath, 'r');
      
      % ensure that exactly two measurements are available
      this.ready = false;
      while(etime(t1, t0)<this.timeOut)
        this.update();
        if(last(this)>=uint32(1))
          this.ready = true;
          break;
        end
        t1 = clock;
      end
      if(~this.ready)
        error(this.timeOutText);
      end
      this.nb = uint32(1);
    end
    
    function refresh(this, x)
      assert(isa(x, 'tom.Trajectory'));
      this.update();
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
      assert(all(isa(n, 'uint32')));
      assert(all(n>=this.na));
      assert(all(n<=this.nb));
      time = zeros(size(n));
      for k = 1:numel(n)
        time(k) = this.initialTime-this.zoneOffset+this.get(n(k), 4);
      end
    end
    
    function force = getSpecificForce(this, n, ax)
      assert(all(isa(n, 'uint32')));
      assert(all(isa(ax, 'uint32')));
      assert(all(ax<=2));
      assert(all(n>=this.na));
      assert(all(n<=this.nb));
      force = zeros(numel(n), numel(ax));
      k = 1;
      for j = uint32(0:(numel(ax)-1))
        for i = uint32(0:(numel(n)-1))
          force(k) = this.get(n(i), ax(j));
        end
      end
    end
    
    function force = getSpecificForceCalibrated(this, n, ax)
      force = getSpecificForce(this, n, ax);
    end
    
    function sigma = getAccelerometerTurnOnBiasSigma(this)
      sigma = this.biasTurnOn;
    end
    
    function sigma = getAccelerometerInRunBiasSigma(this)
      sigma = this.biasSteadyState;
    end
    
    function tau = getAccelerometerInRunBiasStability(this)
      tau = this.biasDecay;
    end
    
    function sigma = getAccelerometerTurnOnScaleSigma(this)
      sigma = this.scaleTurnOn;
    end
    
    function sigma = getAccelerometerInRunScaleSigma(this)
      sigma = this.scaleSteadyState;
    end
    
    function tau = getAccelerometerInRunScaleStability(this)
      tau = this.scaleDecay;
    end
    
    function sigma = getAccelerometerRandomWalk(this)
      sigma = this.randomWalk;
    end
    
    function delete(this)
      unix(['killall -9 ', this.smsApp]);
      try
        fclose(this.fid);
      catch err
        if(this.verbose)
          fprintf('%s', err.message);
        end
      end
    end
  end
  
  methods (Access = private)
    function update(this)
      fseek(this.fid, 0, 1);
      sz = ftell(this.fid);
      this.nb = uint32(max(0, floor(sz/this.lineSkip)-1));
    end
    
    function v = get(this, n, ax)
      persistent pn pt pax pay paz
      if(isempty(pn)||(n~=pn))
        assert(n>=this.na);
        assert(n<=this.nb);
        pn = n;
        fseek(this.fid, 40*n, -1);
        s = fgetl(this.fid);
        pt = str2double(s(1:12));
        pax = str2double(s(14:21));
        pay = str2double(s(23:30));
        paz = str2double(s(32:39));
      end
      switch(ax)
        case uint32(0)
          v = pax;
        case uint32(1)
          v = pay;
        case uint32(2)
          v = paz;
        otherwise
          v = pt;
      end
    end
  end
end
