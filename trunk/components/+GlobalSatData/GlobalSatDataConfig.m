classdef GlobalSatDataConfig < handle
  properties (Constant = true, GetAccess = protected)   
    % Raw GPS data file recorded from a stationary sensor
    %   Used to generate a realistic simulation of errors
    %   Must contain NMEA formatted $GPGGA strings
    %   Lines that do not begin with $GPGGA are skipped
    rawGPSfile = 'gtGPSdata.txt';

    % horizontal  dilution of precision
    hDOP = 5.5; % (5.5)
    
    % vertical dilution of precision
    vDOP = 5.4; % (5.4)
    
    % Standard deviation of equivalent circular error based on environment and hardware (meters)
    sigmaR = 6.7; % (6.7)
  end
end
