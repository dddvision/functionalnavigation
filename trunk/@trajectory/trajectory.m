classdef trajectory
  properties
  end  
  methods (Access=protected)
    % TODO: enforce subclass constructor that takes argument v
    function this=trajectory
    end
  end
  methods (Access=public,Abstract=true)
    % Return the endpoints of the closed time domain of a trajectory
    %
    % OUTPUT
    % a = time domain lower bound
    % b = time domain upper bound
    [a,b]=domain(this);
    
    % Evaluate a single trajectory at multiple time instants
    %
    % INPUT
    % t = time in seconds, 1-by-N
    %
    % OUTPUT
    % posquat = position and quaternion at each time, 7-by-N
    %
    % NOTE
    % Axis order is forward-right-down relative to the base reference frame
    posquat=evaluate(this,t);
  end
end
