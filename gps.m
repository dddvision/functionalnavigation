% This class defines a single global positioning sensor 
classdef gps < sensor
    
  methods (Abstract=true)
    % Get antenna offset relative to the body frame
    %
    % OUTPUT
    % offset = position of antenna origin in the body frame, double 3-by-1
    offset=getAntennaOffset(this);
    
    % Get a position measurement
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % lon = longitude in radians, double scalar
    % lat = latitude in  radians, double scalar
    % alt = altitude above WGS84 ellipsoid in meters, double scalar
    %
    % NOTES
    % Throws an exception if the data index is out of range
    [lon,lat,alt]=getGlobalPosition(this,k);
 
    % Check whether precision information is available
    % 
    % OUTPUT
    % flag = true if precision data is available, false otherwise, bool
    flag=hasPrecision(this);
    
    % Get precision information
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT 
    % hDop = horizontal dilution of precision (unitless), double scalar
    % vDop = vertical dilution of precision (unitless), double scalar
    % sigmaR = standard deviation of equivalent circular error (meters), double scalar
    %
    % NOTES
    % Throws an exception if the data index is out of range
    [hDop,vDop,sigmaR]=getPrecision(this,k);
  end 
 
end
