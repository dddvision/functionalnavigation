classdef GpsSim < GlobalSatData.GlobalSatDataConfig & GPSReceiver
  
  properties
    refData
    ka
    kb
    time
    lat
    lon
    alt
    hDOP
    vDOP
    refTraj
    measurementTimes
    noise
    precisionFlag
    offset
    ready
  end
  
  methods (Access=public)
    function this=GpsSim
      % Read the configuration file
      this.refData = readGPSdataFile(this.referenceTrajectoryFile);
      
      % Read the noise errors from real Global Sat gps data file
      this.noise = readNoiseData('gtGPSdata.txt'); % Error samples (easting, northing, altitude)
      this.refTraj = GlobalSatData.BodyReference;
      [ta,tb] = domain(this.refTraj);
      tdelta = tb-ta;
      this.noise = this.noise(:,this.noise(1,:)<tdelta);
      this.precisionFlag = true;
      this.offset = [0;0;0];
      N=size(this.noise,2);
      this.ka = uint32(1);
      this.kb = uint32(N);
      this.ready = logical(N>0);
    end
    
    function refresh(this)
      isa(this,'GPSReceiver');
    end
    
    function flag=hasData(this)
      flag=this.ready;
    end
    
    function ka=first(this)
      assert(this.ready)
      ka=this.ka;
    end

    function kb=last(this)
      assert(this.ready)
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      ta=domain(this.refTraj);
      time=ta+this.noise(1,k);
    end

    function [lon,lat,alt]=getGlobalPosition(this,k)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      
      % Evaluate the reference trajectory at the measurement time
      pose=evaluate(this.refTraj,getTime(this,k));
      p=cat(2,pose.p);
      [lon,lat,alt] = globalSatData.ecef2lolah(p(1,:),p(2,:),p(3,:));
      
      % Add error based on real Global Sat gps data
      lon = lon+this.noise(2,k);
      lat = lat+this.noise(3,k);
      alt = alt+this.noise(4,k);
    end
    
    function flag = hasPrecision(this)
      flag=this.precisionFlag;
    end
    
    % Picks the closest vDOP and hDOP in the data to the requested index
    function [vDOP,hDOP,sigmaR] = getPrecision(this,k)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      
      timeDiff = abs(getTime(this,k)-this.refData.time);
      nearestDataIndx = find(timeDiff==min(timeDiff));
      vDOP = this.refData.vDOP(nearestDataIndx);
      hDOP = this.refData.hDOP(nearestDataIndx);
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
function refData=readGPSdataFile(fname)
  currdir = fileparts(mfilename('fullpath'));
  full_fname = fullfile(currdir, fname);

  csvdata = csvread(full_fname);

  % Only keep measurements that are made in increasing order of time
  gpsTime = csvdata(:,1);
  keepIndx = logical([diff(gpsTime);1] >= 0);
  csvdata = csvdata(keepIndx,:);

  refData.time = csvdata(:,1);
  refData.lon = csvdata(:,2);
  refData.lat = csvdata(:,3);
  refData.alt = csvdata(:,4);
  refData.hDOP = csvdata(:,5);
  refData.vDOP = csvdata(:,6);
end

% Read a text file that contains an ascii GPS data stream
% Data is read from the line that begins with $GPGGA
%
% NOTES
% Refer to data formats at
% http://www.gpsinformation.org/dale/nmea.htm#GSA
function noise=readNoiseData(fname)
  currdir = fileparts(mfilename('fullpath'));
  full_fname = fullfile(currdir, fname);

  fid = fopen(full_fname,'r');
  str = fgetl(fid);
  counter = 0;
  while str ~= -1
    if strmatch(str(1:6), '$GPGGA')

      counter = counter + 1;
      
      % collect all outputs from strread, then use those that are needed
      [strId, time, latstr, latDir, lonstr, lonDir, quality, numSat, ...
        precision, alt,mStr1,geoidalSep, mStr2, ...
        ageData, stationId] = ...
        strread(str,'%s %s %s %s %s %s %d %d %f %f %s %f %s %f %s', ...
        'delimiter',',');

      [lond,latd] = ll_string2deg(latstr,lonstr);

      if strmatch(latDir, 'W')
        latd = -latd;
      end

      if strmatch(lonDir, 'S');
        lond = -lond;
      end
      
      % length of T,X,Y,Z are not known in advance
      T(counter) = str2double(time);
      A(counter) = (pi/180)*lond;
      B(counter) = (pi/180)*latd;
      C(counter) = alt;
    end
    str = fgetl(fid);
  end
  fclose(fid);

  noise = zeros(4,counter);
  noise(1,:) = T(:) - T(1);
  noise(2,:) = A(:) - mean(A);
  noise(3,:) = B(:) - mean(B);
  noise(4,:) = C(:) - mean(C);
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
