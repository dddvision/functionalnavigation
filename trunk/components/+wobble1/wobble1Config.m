classdef wobble1Config < handle
  
  properties (Constant=true,GetAccess=protected)
    dim=6;
    scalep=0.02;
    scaleq=0.1;
    omegabits=6;
    scaleomega=10;
    initialPosition = [0;0;0];
    initialRotation = [1;0;0;0];
    initialPositionRate = [0;0;0];
    initialRotationRate = [0;0;0;0];
  end
  
end
