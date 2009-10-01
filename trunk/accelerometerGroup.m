% NOTES
% Body frame axis order is forward-right-down
% Using SI units (meters, seconds, radians)
% If you need to add optional device methods, then inherit from this class
% TODO: define exceptions for invalid indices and other errors
classdef accelerometerGroup < sensor
  
  methods
    % Get list of acccelerometer identifiers in the group
    %
    % OUTPUT
    % idList = list of identifiers, uint32 N-by-1
    idList=getIDlist(this);
    
    % Get time step associated with an accelerometer
    %
    % INPUT
    % id = identifier, uint32 scalar
    %
    % OUTPUT
    % timeStep = time step, double scalar
    timeStep=getTimeStep(this,id);
    
    % Get accelerometer position and orientation relative to the body frame
    %
    % INPUT
    % id = identifier, uint32 scalar
    %
    % OUTPUT
    % offset = position and unit normalized direction vector, double 6-by-1
    offset=getOffset(this,id);
    
    % Get raw accelerometer data
    %
    % INPUT
    % id = identifier, uint32 scalar
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % specificForce = average specific force during the time step preceeding the node, double scalar
    %
    % NOTES
    % Specific force is a raw measurement in the sense that it does not compensate for gravity
    % The measurement is taken about the direction of the accelerometer at
    %   the beginning of the preceeding time step
    specificForce=getSpecificForce(this,id,k);
  end
  
end
