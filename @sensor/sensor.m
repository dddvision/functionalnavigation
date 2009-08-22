classdef sensor < seed
  methods (Access=protected)
    function this=sensor
    end
  end
  methods (Access=public,Abstract=true)
    % Evaluate cost associated with trajectory and sensor noise sets
    %
    % INPUTS
    % x = trajectory objects, 1-by-K cell array
    % tmin = time domain lower bound
    % tmax = time domain upper bound
    %
    % OUTPUT
    % c = cost, 1-by-K
    %
    % NOTE
    % The input trajectory objects represent the motion of the body frame
    % relative to a world frame.  If the sensor frame is not coincident with
    % the body frame, then transformations may be necessary.
    c=evaluate(this,x,tmin,tmax);
  end
end
