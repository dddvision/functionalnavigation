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
      simConfig = globalSatData.configGPSsimulator;
      this.gpsData = readGPSdataFile(simConfig.TLoLaAltFile);
      this.sigmaR = simConfig.sigmaR;
      if simConfig.interpTraj
        this.measurementTimes = ceil(this.gpsData.time(1)):floor(this.gpsData.time(end));
      else
        this.measurementTimes = this.gpsData.time;
      end
      
      this.xyzErrors = globalSatData.readNoiseData('gtGPSdata.txt'); % Error samples (easting, northing, altitude)
      this.refTraj = globalSatData.bodyReference;
      this.isLocked = false;
    end
    
    function [ka,kb]=domain(this)
      assert(this.isLocked);
      ka=uint32(1);
      kb=uint32(length(this.measurementTimes));
    end
    
    function time=getTime(this,k)
      time=this.measurementTimes(k);
    end
    
    function [lon, lat, alt] = getPosition(this,k)
      posquat = evaluate(this.refTraj, this.measurementTimes(k));
      true_lon = posquat(1);
      true_lat = posquat(2);
      true_alt = posquat(3);
      [true_X, true_Y, true_Z] = ...
        globalSatData.lolah2ecef(true_lon, true_lat, true_alt);
      
      % Add random error
      numErrSamples = size(this.xyzErrors,1);
      noiseSample = 1+mod(k, numErrSamples-1);
      
      X = true_X+this.xyzErrors(noiseSample, 1);
      Y = true_Y+this.xyzErrors(noiseSample, 2);
      Z = true_Z+this.xyzErrors(noiseSample,3);
      
      [lon, lat, alt] = globalSatData.ecef2lolah(X, Y, Z);
    end
    
    function flag = hasPrecision(this)
      
      flag = 1;
      
    end
    
    
    
    function [vDOP, hDOP, sigmaR] = getPrecision(this,k)
      
      % Pick the closest vDOP and hDOP in the data to
      % the requested index
      
      currTime = this.measurementTimes(k);
      nearestDataIndx = find(min(abs(currTime-this.gpsData.time)));
      vDOP = this.gpsData.vDOP(nearestDataIndx);
      hDOP = this.gpsData.hDOP(nearestDataIndx);
      sigmaR = this.sigmaR;
    end
    
    function offset = getOffset(this)
      offset = [0 0 0];
    end
    
    function lock(this)
      this.isLocked=true;
    end
    
    function unlock(this)
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
gpsData.time = csvdata(:,1);
gpsData.lon = csvdata(:,2);
gpsData.lat = csvdata(:,3);
gpsData.alt = csvdata(:,4);
gpsData.hDOP = csvdata(:,5);
gpsData.vDOP = csvdata(:,6);
end