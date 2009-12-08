% This class augments a trajectory with defining parameters
classdef dynamicModel < trajectory
  
  properties (Constant=true,GetAccess=public)
    baseClass='dynamicModel';
  end
  
  methods (Abstract=true)
    % Extract a tail segment of dynamic parameters
    %
    % INPUT
    % tmin = time lower bound, double scalar
    %
    % OUTPUT
    % bits = bitset segment of dynamic parameters, logical 1-by-nvars
    bits=getBits(this,tmin);

    % Replace a tail segment of dynamic parameters
    % 
    % INPUT
    % bits = bitset segment of dynamic parameters to splice in, logical 1-by-nvars
    % tmin = time lower bound, double scalar
    % 
    % NOTES
    % This operation will change the derived class behaviour
    this=putBits(this,bits,tmin);
  end
  
%   methods (Static=true,Abstract=true)
%     % Calculate the prior cost of a set of parameters
%     %
%     % INPUT
%     % bits = bitset segment of dynamic parameters, logical 1-by-nvars
%     % tmin = time lower bound, double scalar
%     %
%     % OUTPUT
%     % cost = non-negative prior cost, double scalar
%     cost=priorCost(bits,tmin);
%   end
    
end
