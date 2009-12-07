classdef gpsSim < gps
  
  properties
    gpsData
    ka
    kb
    time
    lat
    lon
    alt
    hDOP
    vDOP
    sigmaR
    isLocked
    refTraj
    measurementTimes
    xyzErrors
  end
  
  
  methods (Access=public)
    function this=gpsSim
      % Read the configuration file
      simConfig = globalSatData.configGPSsimulator;
      this.gpsData = readGPSdataFile(simConfig.TLoLaAltFile);
      this.sigmaR = simConfig.sigmaR;
      
      % If trajectory is to be interolated, find times at which data
      % must be made available
      if simConfig.interpTraj
        this.measurementTimes = ceil(this.gpsData.time(1)):floor(this.gpsData.time(end));
      else
        this.measurementTimes = this.gpsData.time;
      end
      
      % Read the noise errors from real Global Sat gps data file
      this.xyzErrors = globalSatData.readNoiseData('gtGPSdata.txt'); % Error samples (easting, northing, altitude)
      this.refTraj = globalSatData.bodyReference;
      this.isLocked = false;
    end
    
    function [ka,kb]=dataDomain(this)
      % Return first and last indices of a consecutive list of data elements
      assert(this.isLocked);
      ka=uint32(1);
      kb=uint32(length(this.measurementTimes));
    end
    
    function time=getTime(this,k)
      % Get time stamp at required data index
      % Return value is NaN when the data index is invalid
      time=this.measurementTimes(k);
    end
    
    function [lon, lat, alt] = getGlobalPosition(this,k)
      % Get a position (lon,lat,alt) measurement
      
      % Evaluate the reference trajectory at the measurement time
      posquat = evaluate(this.refTraj, this.measurementTimes(k));
      true_lon = posquat(1);
      true_lat = posquat(2);
      true_alt = posquat(3);
      
      % Convert true (lon,lat,alt) coordinates to ECEF coordinates
      [true_X, true_Y, true_Z] = ...
        globalSatData.lolah2ecef(true_lon, true_lat, true_alt);
      
      % Add error based on real Global Sat gps data
      numErrSamples = size(this.xyzErrors,1);
      noiseSample = 1+mod(k, numErrSamples-1);
      
      X = true_X+this.xyzErrors(noiseSample, 1);
      Y = true_Y+this.xyzErrors(noiseSample, 2);
      Z = true_Z+this.xyzErrors(noiseSample,3);
      
      % Convert noisy ECEF positions to (lon,lat,alt)
      [lon, lat, alt] = globalSatData.ecef2lolah(X, Y, Z);
    end
    
    function flag = hasPrecision(this)
      % Check whether precision information is available
      % flag = true if precision data is available, false otherwise
      flag = true;
    end
    
    function [vDOP, hDOP, sigmaR] = getPrecision(this,k)
      % Get GPS precision  data
      
      % Pick the closest vDOP and hDOP in the data to
      % the requested index
      currTime = this.measurementTimes(k);
      nearestDataIndx = find(min(abs(currTime-this.gpsData.time)));
      vDOP = this.gpsData.vDOP(nearestDataIndx);
      hDOP = this.gpsData.hDOP(nearestDataIndx);
      sigmaR = this.sigmaR;
    end
    
    function offset = getAntennaOffset(this)
      % Get antenna offset relative to the body frame
      offset = [0 0 0];
    end
    
    function lock(this)
      % Temporarily lock the data buffer of this sensor
      this.isLocked=true;
    end
    
    function unlock(this)
      % Unlock the data buffer of this sensor
      this.isLocked=false;
    end
  end
end

function gpsData=readGPSdataFile(fname)
% Read a csv file that contains ascii GPS data
% Each line has the
% Time Lon Lat Alt hDop vDop
% Time --> Seconds since midnight on Jan 6, 1980 (double)
% Lon  --> Longitude in radians  (double)
% Lat --> Latitude in radians (double)
% Alt --> Altitude in meters (double)
% hDop --> Horizontal dilution of precision (double)
% vDop --> Vertical dilution of precision (double)

maindir = pwd;
currdir = [maindir '/components/+globalSatData'];
full_fname = fullfile(currdir, fname);

csvdata = csvread(full_fname);

% Only keep measurements that are made in increasing order
% of time

gpsTime = csvdata(:,1);
keepIndx = 1;
lastTime = gpsTime(1);
for indx = 2:length(gpsTime)
  if gpsTime(indx) > lastTime
    keepIndx = [keepIndx indx];
    lastTime = gpsTime(indx);
  end
end

csvdata = csvdata(keepIndx,:);
gpsData.time = csvdata(:,1);
gpsData.lon = csvdata(:,2);
gpsData.lat = csvdata(:,3);
gpsData.alt = csvdata(:,4);
gpsData.hDOP = csvdata(:,5);
gpsData.vDOP = csvdata(:,6);


end