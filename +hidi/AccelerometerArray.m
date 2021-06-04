classdef AccelerometerArray < hidi.Sensor
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = protected, Static = true)
    function this = AccelerometerArray()
    end
  end
    
  methods (Access = public, Abstract = true)
    force = getSpecificForce(this, n, ax);
    walk = getAccelerometerRandomWalk(this);
    sigma = getAccelerometerTurnOnBiasSigma(this);
    sigma = getAccelerometerInRunBiasSigma(this);
    tau = getAccelerometerInRunBiasStability(this);
    sigma = getAccelerometerTurnOnScaleSigma(this);
    sigma = getAccelerometerInRunScaleSigma(this);
    tau = getAccelerometerInRunScaleStability(this);
  end
end
