classdef AccelerometerArray < hidi.Sensor
  methods (Static = true, Access = protected)
    function this = AccelerometerArray()
    end
  end
    
  methods (Abstract = true, Access = public)
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
