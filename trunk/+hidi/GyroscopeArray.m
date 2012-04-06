classdef GyroscopeArray < hidi.Sensor
  methods (Abstract = true)
    rate = getAngularRate(this, n, ax);
    walk = getGyroscopeAngleRandomWalk(this);
    sigma = getGyroscopeTurnOnBiasSigma(this);
    sigma = getGyroscopeInRunBiasSigma(this);
    tau = getGyroscopeInRunBiasStability(this);
    sigma = getGyroscopeTurnOnScaleSigma(this);
    sigma = getGyroscopeInRunScaleSigma(this);
    tau = getGyroscopeInRunScaleStability(this);
  end
end
