classdef AccelerometerArray < hidi.Sensor
  methods (Abstract = true)
    force = getSpecificForce(this, n, ax);
    walk = getAccelerometerVelocityRandomWalk(this);
    sigma = getAccelerometerTurnOnBiasSigma(this);
    sigma = getAccelerometerInRunBiasSigma(this);
    tau = getAccelerometerInRunBiasStability(this);
    sigma = getAccelerometerTurnOnScaleSigma(this);
    sigma = getAccelerometerInRunScaleSigma(this);
    tau = getAccelerometerInRunScaleStability(this);
  end
end
