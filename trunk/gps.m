% This class defines a single gps sensor 
% If you need to add optional device methods, then inherit from this class
% Using SI units (meters, seconds, radians)
classdef gps < sensor
    
  methods (Abstract=true)
    % Get sensor position relative to the body frame
    %
    % INPUT
    % k = zero-based sensor index, uint32 scalar
    %
    % OUTPUT
    % offset = position of origin, double 3-by-1
    % direction = unit normalized direction vector, 3-by-1
    offset=getSensorPos(this,k);
    
    % Get a position measurement
    %
    % INPUT
    % k = zero-based sensor index, uint32 scalar
    %
    % OUTPUT
    % lon = longitude in radians, double scalar
    % lat = latitude in  radians, double scalar
    % alt = altitude above WGS84 ellipsoid in meters, double scalar
    [lon,lat,alt] = getPosition(this,k);
    
    % Get GPS precision information %
    % INPUT
    % k = zero-based sensor index, uint32 scalar
    %
    % OUTPUT 
    % hDop = horizontal dilution  of precision (unitless), double scalar
    % vDop = vertical dilution of precision (unitless), double scalar
    % sigmaR = standard deviation for range error (meters), double scalar
    [hDop,vDop, sigmaR] = getPrecision(this, k);
    
    % Check whether precision information is available
    % 
    % OUTPUT
    % flag = true if precision data is available from the sensor, 
    %        false otherwise, bool
    flag = hasPrecision(this);
   
  end 
 
end
