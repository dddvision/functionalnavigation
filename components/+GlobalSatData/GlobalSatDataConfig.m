classdef GlobalSatDataConfig < handle
  
  properties (Constant=true,GetAccess=protected)
    % File containing a list of points that define a reference trajectory
    % Must contain comma separated data in the following form:
    %   time, lon, lat, alt, hDOP, vDOP
    %   time =  gps time (seconds since 12.00 am Jan 6, 1980)
    %   lon  =  longitude in  radians
    %   lat  =  latitude in radians
    %   alt  =  height above WGS84 ellipsoid in meters
    %   hDOP =  horizontal  dilution of precision
    %   vDOP =  vertical dilution of precision
    referenceTrajectoryFile = 'testTraj.txt';
    
    % Raw GPS data file recorded from a stationary sensor
    %   Used to generate a realistic simulation of errors
    %   Must contain NMEA formatted $GPGGA strings
    %   Lines that do not begin with $GPGGA are skipped
    rawGPSfile = 'gtGPSdata.txt';
    
    % Cardinal spline tension parameter
    splineTension = 0;
    
    % Standard deviation of equivalent circular error (meters)
    sigmaR = 6.7; % should be based on environment and hardware
  end
  
end
