classdef GyroscopeArray < hidi.Sensor
  methods (Static = true, Access = protected)
    function this = GyroscopeArray()
    end
  end
  
  methods (Abstract = true, Access = public)
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
