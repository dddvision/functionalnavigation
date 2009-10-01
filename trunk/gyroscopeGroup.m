% NOTES
% Body frame axis order is forward-right-down
% Using SI units (meters, seconds, radians)
% If you need to add optional device methods, then inherit from this class
% TODO: define exceptions for invalid indices and other errors
classdef gyroscopeGroup < sensor
  
  methods (Abstract=true)
    % Get list of gyroscope identifiers within this group
    %
    % OUTPUT
    % gyroID = list of member identifiers, uint32 N-by-1
    gyroID=getGyroID(this);
    
    % Get time step or period associated with this gyroscope group
    %
    % OUTPUT
    % timeStep = time step, double scalar
    timeStep=getTimeStep(this);
    
    % Get gyroscope position and orientation relative to the body frame
    %
    % INPUT
    % gyroID = member identifier, uint32 scalar
    %
    % OUTPUT
    % offset = position and unit normalized direction vector, double 6-by-1
    offset=getOffset(this,gyroID);
    
    % Get raw gyroscope data
    %
    % INPUT
    % gyroID = member identifier, uint32 scalar
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % averageRate = average angular rate during the time step preceeding the node, double scalar
    %
    % NOTES
    % Average angular rate is a raw measurement from a typical integrating gyroscope
    % The rate is measured via right-hand rule about the direction of the 
    %   gyroscope at the beginning of the preceeding time step
    averageRate=getAverageRate(this,gyroID,k);
  end
  
end
