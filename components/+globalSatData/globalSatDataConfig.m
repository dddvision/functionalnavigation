classdef globalSatDataConfig
  
  properties (Constant=true)
    %  Specify input filename 
    %  File must contain comma separated data in the following form
    %     time, lon, lat, alt, hDOP, vDOP
    %     time =  gps time (seconds since 12.00 am Jan 6, 1980)
    %     lon  =  longitude in  radians
    %     lat  =  latitude in radians
    %     alt  =  height above WGS84 ellipsoid in meters
    %     hDOP =  horizontal  dilution of precision
    %     vDOP =  vertical dilution of precision
    TLoLaAltFile = 'testTraj.txt';
    
    % Flag to determine if simulator should interpolate given  trajectory points
    % If 'true', gps data is simulated at one second intervals
    interpTraj = true;
    
    % Cardinal spline tension parameter (used if interpTraj is 'true')
    splineTension = 0;
    
    % Standard deviation of equivalent circular error (meters)
    sigmaR = 6.7; % should be based on environment and hardware
  end
  
end
