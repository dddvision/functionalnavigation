classdef sensor < seed
  methods (Access=protected)
    function this=sensor
    end
  end
  methods (Access=public,Abstract=true)
    % Evaluate cost associated with sets of sensor and trajectory objects
    %
    % INPUTS
    % this = sensor objects, K-by-1
    % x = trajectory objects, K-by-1
    % tmin = time domain lower bound
    % tmax = time domain upper bound
    %
    % OUTPUT
    % c = cost, K-by-1
    %
    % NOTE
    % The input trajectory objects represent the motion of the body frame
    % relative to a world frame.  If the sensor frame is not coincident with
    % the body frame, then transformations may be necessary.
    c=evaluate(this,x,tmin,tmax);
  end
end
