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
    txyzErrors
    precisionFlag
    offset
  end
  
  methods (Access=public)
    function this=gpsSim
      % Read the configuration file
      config = globalSatData.globalSatDataConfig;
      this.sigmaR = config.sigmaR;
      this.gpsData = readGPSdataFile(config.referenceTrajectoryFile);
      
      % Read the noise errors from real Global Sat gps data file
      this.txyzErrors = readNoiseData('gtGPSdata.txt'); % Error samples (easting, northing, altitude)
      this.refTraj = globalSatData.bodyReference;
      this.isLocked = false;
      this.precisionFlag = true;
      this.offset = [0;0;0];
      this.ka = uint32(1);
      this.kb = uint32(size(this.txyzErrors,1));
    end
    
    function [ka,kb]=dataDomain(this)
      assert(this.isLocked);
      ka=this.ka;
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(k>=this.ka);
      assert(k<=this.kb);
      
      ta=domain(this.refTraj);
      numErrSamples = size(this.txyzErrors,1);
      noiseSample = 1+mod(k,numErrSamples-1);
      time = ta + this.txyzErrors(noiseSample,1);
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
      ecef = evaluate(this.refTraj,getTime(this,k));
      true_X = ecef(1);
      true_Y = ecef(2);
      true_Z = ecef(3);
      
      numErrSamples = size(this.txyzErrors,1);
      noiseSample = 1+mod(k,numErrSamples-1);
      
      % Add error based on real Global Sat gps data
      X = true_X+this.txyzErrors(noiseSample,2);
      Y = true_Y+this.txyzErrors(noiseSample,3);
      Z = true_Z+this.txyzErrors(noiseSample,4);
      
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

  % Only keep measurements that are made in increasing order of time

  gpsTime = csvdata(:,1);
  keepIndx = logical([diff(gpsTime);1] >= 0);

  csvdata = csvdata(keepIndx,:);
  gpsData.time = csvdata(:,1);
  gpsData.lon = csvdata(:,2);
  gpsData.lat = csvdata(:,3);
  gpsData.alt = csvdata(:,4);
  gpsData.hDOP = csvdata(:,5);
  gpsData.vDOP = csvdata(:,6);
end

% Read a text file that contains an ascii GPS data stream
% Data is read from the line that begins with $GPGGA
%
% NOTES
% Refer to data formats at
% http://www.gpsinformation.org/dale/nmea.htm#GSA
function txyzErrors=readNoiseData(fname)
  maindir = pwd;
  currdir = [maindir '/components/+globalSatData'];
  full_fname = fullfile(currdir, fname);

  fid = fopen(full_fname,'r');
  counter = 0;

  str = fgetl(fid);

  while str ~= -1
    if strmatch(str(1:6), '$GPGGA')

      counter = counter + 1;
      
      % collect all outputs from strread, then use those that are needed
      [strId, time, lat, latDir, long, longDir, quality, numSat, ...
        precision, antennaAltitude,mStr1,geoidalSep, mStr2, ...
        ageData, stationId] = ...
        strread(str,'%s %s %s %s %s %s %d %d %f %f %s %f %s %f %s', ...
        'delimiter',',');

      [long, lat] = ll_string2deg(lat,long);

      if strmatch(latDir, 'W')
        lat = -lat;
      end

      if strmatch(longDir, 'S');
        long = -long;
      end
      
      % length of T,X,Y,Z are not known in advance
      T(counter) = str2double(time);
      [X(counter), Y(counter), Z(counter)] = ...
        globalSatData.lolah2ecef((pi/180)*long, (pi/180)*lat, antennaAltitude);
    end
    str = fgetl(fid);
  end
  fclose(fid);

  txyzErrors(:,1) = T - T(1);
  txyzErrors(:,2) = X - mean(X);
  txyzErrors(:,3) = Y - mean(Y);
  txyzErrors(:,4) = Z - mean(Z);
end

% INPUTS
% lat = string of the form ddmm.mmmm
% long = string of the form dddmm.mmmm
function [lat_dec,long_dec] = ll_string2deg(lat, long)
  lat = char(lat);
  long = char(long);
  lat_dec = str2double(lat(1:2)) + str2double(lat(3:end))./60;
  long_dec = str2double(long(1:3)) + str2double(long(4:end))./60;
end

% function [lat_str,long_str] = ll_deg2string(lat, long)
%   lat_min = mod(lat,1)*60;
%   lat_str = sprintf('%02d%07.4f', floor(lat), lat_min);
%   long_min = mod(long,1)*60;
%   long_str = sprintf('%03d%07.4f', floor(long), long_min);
% end
