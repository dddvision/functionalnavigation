% NOTES
% Body frame axis order is forward-right-down
% Using SI units (meters, seconds, radians)
% If you need to add optional device methods, then inherit from this class
% TODO: define exceptions for invalid indices and other errors
classdef accelerometerGroup < sensor
  
  methods (Abstract=true)
    % Get list of acccelerometer identifiers within this group
    %
    % OUTPUT
    % accelID = list of member identifiers, uint32 N-by-1
    accelID=getAccelID(this);
    
    % Get time step or period associated with this accelerometer group
    %
    % OUTPUT
    % timeStep = time step, double scalar
    timeStep=getTimeStep(this);
    
    % Get accelerometer position and orientation relative to the body frame
    %
    % INPUT
    % accelID = member identifier, uint32 scalar
    %
    % OUTPUT
    % offset = position and unit normalized direction vector, double 6-by-1
    offset=getOffset(this,accelID);
    
    % Get raw accelerometer data
    %
    % INPUT
    % accelID = member identifier, uint32 scalar
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % specificForce = average specific force during the time step preceeding the node, double scalar
    %
    % NOTES
    % Specific force is a raw measurement in the sense that it does not compensate for gravity
    % The measurement is taken about the direction of the accelerometer at
    %   the beginning of the preceeding time step
    specificForce=getSpecificForce(this,accelID,k);
  end
  
end
