% NOTES
% Body frame axis order is forward-right-down
% Using SI units (meters, seconds, radians)
% If you need to add optional device methods, then inherit from this class
% TODO: define exceptions for invalid indices and other errors
classdef gyroscopeGroup < sensor
  
  methods
    % Get list of gyroscope identifiers in the group
    %
    % OUTPUT
    % idList = list of identifiers, uint32 N-by-1
    idList=getIDlist(this);
    
    % Get time step associated with a gyroscope
    %
    % INPUT
    % id = identifier, uint32 scalar
    %
    % OUTPUT
    % timeStep = time step, double scalar
    timeStep=getTimeStep(this,id);
    
    % Get gyroscope position and orientation relative to the body frame
    %
    % INPUT
    % id = identifier, uint32 scalar
    %
    % OUTPUT
    % offset = position and unit normalized direction vector, double 6-by-1
    offset=getOffset(this,id);
    
    % Get raw gyroscope data
    %
    % INPUT
    % id = identifier, uint32 scalar
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % averageRate = average angular rate during the time step preceeding the node, double scalar
    %
    % NOTES
    % Average angular rate is a raw measurement from a typical integrating gyroscope
    % The rate is measured via right-hand rule about the direction of the 
    %   gyroscope at the beginning of the preceeding time step
    averageRate=getAverageRate(this,id,k);
  end
  
end
