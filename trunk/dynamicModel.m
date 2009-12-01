% This class augments a trajectory with defining parameters
classdef dynamicModel < trajectory
  
  properties (Constant=true,GetAccess=public)
    baseClass='dynamicModel';
  end
  
  methods (Abstract=true)
    % Extract a tail segment of dynamic parameters from the derived class
    %
    % INPUT
    % tmin = time lower bound, double scalar
    %
    % OUTPUT
    % bits = bitset segment of dynamic parameters, logical D-by-T
    bits=getBits(this,tmin);

    % Replace a tail segment of dynamic parameters held by the derived class
    % 
    % INPUT
    % bits = bitset segment of dynamic parameters to splice in, logical length D*T
    % tmin = time lower bound, double scalar
    % 
    % NOTE
    % This operation will change the derived class behaviour
    this=putBits(this,bits,tmin);
  end
    
end
