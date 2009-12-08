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
    precisionFlag
    offset
  end
  
  methods (Access=public)
    function this=gpsSim
      % Read the configuration file
      simConfig = globalSatData.configGPSsimulator;
      this.gpsData = readGPSdataFile(simConfig.TLoLaAltFile);
      this.sigmaR = simConfig.sigmaR;
      
      % If trajectory is to be interpolated, find times at which data
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
      this.precisionFlag = true;
      this.offset = [0;0;0];
      this.ka=uint32(1);
      this.kb=uint32(length(this.measurementTimes));
    end
    
    function [ka,kb]=dataDomain(this)
      assert(this.isLocked);
      ka=this.ka;
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(k>=this.ka);
      assert(k<=this.kb);
      time=this.measurementTimes(k);
    end
    
    function isLocked=lock(this)
      this.isLocked=true;
      isLocked=this.isLocked;
    end

    function isUnlocked=unlock(this)
      this.isLocked=false;
      isUnlocked=~this.isLocked;
    end
    
    function [lon,lat,alt]=getGlobalPosition(this,k)
      assert(k>=this.ka);
      assert(k<=this.kb);
      
      % Evaluate the reference trajectory at the measurement time
      posquat = evaluate(this.refTraj, this.measurementTimes(k));
      true_lon = posquat(1);
      true_lat = posquat(2);
      true_alt = posquat(3);
      
      % Convert true (lon,lat,alt) coordinates to ECEF coordinates
      [true_X,true_Y,true_Z]=globalSatData.lolah2ecef(true_lon,true_lat,true_alt);
      
      % Add error based on real Global Sat gps data
      numErrSamples = size(this.xyzErrors,1);
      noiseSample = 1+mod(k, numErrSamples-1);
      
      X = true_X+this.xyzErrors(noiseSample, 1);
      Y = true_Y+this.xyzErrors(noiseSample, 2);
      Z = true_Z+this.xyzErrors(noiseSample,3);
      
      % Convert noisy ECEF positions to (lon,lat,alt)
      [lon,lat,alt] = globalSatData.ecef2lolah(X,Y,Z);
    end
    
    function flag = hasPrecision(this)
      flag=this.precisionFlag;
    end
    
    % Picks the closest vDOP and hDOP in the data to the requested index
    function [vDOP,hDOP,sigmaR] = getPrecision(this,k)
      assert(k>=this.ka);
      assert(k<=this.kb);
      
      currTime = this.measurementTimes(k);
      nearestDataIndx = find(min(abs(currTime-this.gpsData.time)));
      vDOP = this.gpsData.vDOP(nearestDataIndx);
      hDOP = this.gpsData.hDOP(nearestDataIndx);
      sigmaR = this.sigmaR;
    end
    
    function offset = getAntennaOffset(this)
      offset=this.offset;
    end
  end
end

% Read a csv file that contains ascii GPS data
% Each line has the
% Time Lon Lat Alt hDop vDop
% Time --> Seconds since midnight on Jan 6, 1980 (double)
% Lon  --> Longitude in radians  (double)
% Lat --> Latitude in radians (double)
% Alt --> Altitude in meters (double)
% hDop --> Horizontal dilution of precision (double)
% vDop --> Vertical dilution of precision (double)
function gpsData=readGPSdataFile(fname)
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
