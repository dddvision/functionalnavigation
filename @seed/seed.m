classdef seed
  methods (Access=protected)
    function this=seed
    end
  end
  methods (Abstract=true,Access=public)

    % Extract a tail segment of dynamic parameters from the derived class
    %
    % INPUT
    % tmin = time lower bound
    %
    % OUTPUT
    % bits = bitset segment of dynamic parameters
    bits=dynamicGet(this,tmin);

    % Replace a tail segment of dynamic parameters held by the derived class
    % 
    % INPUT
    % bits = bitset segment of dynamic parameters to splice in
    % tmin = time lower bound
    % 
    % NOTE
    % This operation will change the derived class behaviour
    this=dynamicPut(this,bits,tmin);

    % Calculate the prior cost of a set of parameters
    %
    % INPUT
    % bits = bitset segment of dynamic parameters
    % tmin = time lower bound
    %
    % OUTPUT
    % cost = prior cost
    cost=priorCost(this,bits,tmin);
    
  end
end
