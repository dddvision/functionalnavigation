classdef GyroscopeArray < hidi.Sensor
  methods (Access = protected, Static = true)
    function this = GyroscopeArray()
    end
  end
  
  methods (Access = public, Abstract = true)
    rate = getAngularRate(this, n, ax);
    walk = getGyroscopeRandomWalk(this);
    sigma = getGyroscopeTurnOnBiasSigma(this);
    sigma = getGyroscopeInRunBiasSigma(this);
    tau = getGyroscopeInRunBiasStability(this);
    sigma = getGyroscopeTurnOnScaleSigma(this);
    sigma = getGyroscopeInRunScaleSigma(this);
    tau = getGyroscopeInRunScaleStability(this);
  end
end
