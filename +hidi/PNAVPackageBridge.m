classdef PNAVPackageBridge < hidi.PNAVPackage & hidi.PNAVPackage & hidi.AccelerometerArray & hidi.GyroscopeArray & hidi.MagnetometerArray & hidi.Altimeter & hidi.GPSReceiver
  properties (SetAccess = protected, GetAccess = protected)
    name
    uri
    m % mex name without extension
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      assert(isa(name, 'char'));
      compileOnDemand(name);
      className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];     
      mName = [className, 'Bridge'];
      function text = componentDescription
        text = feval(mName, 'PNAVPackageDescription', name);
      end
      function obj = componentFactory(uri)
        obj = hidi.PNAVPackageBridge(name, uri);
      end
      if(feval(mName, 'PNAVPackageIsConnected', name))
        hidi.PNAVPackage.connect(name, @componentDescription, @componentFactory);
      end
    end

    function this = PNAVPackageBridge(name, uri)
      if(nargin==0)
        uri = '';
      end
      this = this@hidi.PNAVPackage(uri);
      this = this@hidi.AccelerometerArray();
      this = this@hidi.GyroscopeArray();
      this = this@hidi.MagnetometerArray();
      this = this@hidi.Altimeter();
      this = this@hidi.GPSReceiver();
      if(nargin>0)
        assert(isa(name, 'char'));
        assert(isa(uri, 'char'));
        compileOnDemand(name);
        className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
        this.name = name;
        this.uri = uri;
        this.m = [className, 'Bridge'];
        feval(this.m, 'PNAVPackageCreate', name, uri);
      end
    end
  end
    
  methods (Access = public)    
    function this = getAccelerometerArray(this)
    end
    
    function this = getGyroscopeArray(this)
    end
    
    function this = getMagnetometerArray(this)
    end
    
    function this = getAltimeter(this)
    end
    
    function this = getGPSReceiver(this)
    end
    
    function refresh(this)
      feval(this.m, 'refresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, 'hasData');
    end
    
    function n = first(this)
      n = feval(this.m, 'first');
    end
    
    function n = last(this)
      n = feval(this.m, 'last');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, 'getTime', n);
    end
    
    function force = getSpecificForce(this, n, ax)
      force = feval(this.m, 'getSpecificForce', n, ax);
    end
    
    function force = getSpecificForceCalibrated(this, n, ax)
      force = feval(this.m, 'getSpecificForceCalibrated', n, ax);
    end
    
    function walk = getAccelerometerVelocityRandomWalk(this)
      walk = feval(this.m, 'getAccelerometerVelocityRandomWalk');
    end
    
    function sigma = getAccelerometerTurnOnBiasSigma(this)
      sigma = feval(this.m, 'getAccelerometerTurnOnBiasSigma');
    end
    
    function sigma = getAccelerometerInRunBiasSigma(this)
      sigma = feval(this.m, 'getAccelerometerInRunBiasSigma');
    end
    
    function tau = getAccelerometerInRunBiasStability(this)
      tau = feval(this.m, 'getAccelerometerInRunBiasStability');
    end
    
    function sigma = getAccelerometerTurnOnScaleSigma(this)
      sigma = feval(this.m, 'getAccelerometerTurnOnScaleSigma');
    end
    
    function sigma = getAccelerometerInRunScaleSigma(this)
      sigma = feval(this.m, 'getAccelerometerInRunScaleSigma');
    end
    
    function tau = getAccelerometerInRunScaleStability(this)
      tau = feval(this.m, 'getAccelerometerInRunScaleStability');
    end
    
    function rate = getAngularRate(this, n, ax)
      rate = feval(this.m, 'getAngularRate', n, ax);
    end
    
    function rate = getAngularRateCalibrated(this, n, ax)
      rate = feval(this.m, 'getAngularRateCalibrated', n, ax);
    end
    
    function walk = getGyroscopeAngleRandomWalk(this)
      walk = feval(this.m, 'getGyroscopeAngleRandomWalk');
    end
    
    function sigma = getGyroscopeTurnOnBiasSigma(this)
      sigma = feval(this.m, 'getGyroscopeTurnOnBiasSigma');
    end
    
    function sigma = getGyroscopeInRunBiasSigma(this)
      sigma = feval(this.m, 'getGyroscopeInRunBiasSigma');
    end
    
    function tau = getGyroscopeInRunBiasStability(this)
      tau = feval(this.m, 'getGyroscopeInRunBiasStability');
    end
    
    function sigma = getGyroscopeTurnOnScaleSigma(this)
      sigma = feval(this.m, 'getGyroscopeTurnOnScaleSigma');
    end
    
    function sigma = getGyroscopeInRunScaleSigma(this)
      sigma = feval(this.m, 'getGyroscopeInRunScaleSigma');
    end
    
    function tau = getGyroscopeInRunScaleStability(this)
      tau = feval(this.m, 'getGyroscopeInRunScaleStability');
    end
    
    function field = getMagneticField(this, n, ax)
      field = feval(this.m, 'getMagneticField', n, ax);
    end
    
    function field = getMagneticFieldCalibrated(this, n, ax)
      field = feval(this.m, 'getMagneticFieldCalibrated', n, ax);
    end
    
    function altitude = getAltitude(this, n)
      altitude = feval(this.m, 'getAltitude', n);
    end

    function longitude = getLongitude(this, n)
      longitude = feval(this.m, 'getLongitude', n);
    end

    function latitude = getLatitude(this, n)
      latitude = feval(this.m, 'getLatitude', n);
    end
    
    function height = getHeight(this, n)
      height = feval(this.m, 'getHeight', n);
    end
    
    function flag = hasPrecision(this)
      flag = feval(this.m, 'hasPrecision');
    end
    
    function horizontal = getPrecisionHorizontal(this, n)
      horizontal = feval(this.m, 'getPrecisionHorizontal', n);
    end
    
    function vertical = getPrecisionVertical(this, n)
      vertical = feval(this.m, 'getPrecisionVertical', n);
    end
    
    function circular = getPrecisionCircular(this, n)
      circular = feval(this.m, 'getPrecisionCircular', n);
    end
  end
end

function compileOnDemand(name)
  persistent tried
  if(~isempty(tried))
    return;
  end
  tried = true;
  bridge = mfilename('fullpath');
  bridgecpp = [bridge, '.cpp'];
  include1 = ['-I"', fileparts(bridge), '"'];
  include2 = ['-I"', fileparts(which('hidi.WorldTime')), '"'];
  base = fullfile(['+', name], name);
  basecpp = [base, '.cpp'];
  cpp = which(basecpp);
  output = [cpp(1:(end-4)), 'Bridge'];
  if(exist(output, 'file'))
    delete([output, '.', mexext]);
  end
  mex(include1, include2, bridgecpp, cpp, '-output', output);
end
