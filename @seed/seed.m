classdef seed
  methods (Access=protected)
    function this=seed
    end
  end
  methods (Abstract=true,Access=public)

    % Extract static parameters from the derived class
    %
    % OUTPUT
    % bits = bitset of static parameters
    bits=staticGet(this);
    
    % Replace static parameters held by the derived class
    %
    % INPUT
    % bits = bitset of static parameters
    %
    % NOTE
    % This operation will change the derived class behaviour
    this=staticSet(this,bits);
    
    % Extract a contiguous subset of dynamic parameters from the derived class
    %
    % INPUT
    % tmin = time lower bound
    % tmax = time upper bound
    %
    % OUTPUT
    % bits = bitset segment of dynamic parameters
    bits=dynamicGet(this,tmin,tmax);

    % Replace a contiguous subset of dynamic parameters held by the derived class
    % 
    % INPUT
    % bits = bitset segment of dynamic parameters to splice in
    % tmin = time lower bound
    % tmax = time upper bound
    % 
    % NOTE
    % This operation will change the derived class behaviour
    this=dynamicSet(this,bits,tmin,tmax);

    % Calculate the prior cost of a set of parameters
    %
    % INPUT
    % staticBits = bitset of static parameters
    % dynamicBits = bitset segment of dynamic parameters
    % tmin = time lower bound
    % tmax = time upper bound
    %
    % OUTPUT
    % cost = prior cost
    cost=priorCost(this,staticBits,dynamicBits,tmin,tmax);
    
  end
end
