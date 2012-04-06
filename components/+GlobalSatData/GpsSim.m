classdef GpsSim < GlobalSatData.GlobalSatDataConfig & antbed.GPSReceiver
  
  properties
    na
    nb
    time
    lat
    lon
    alt
    refTraj
    measurementTimes
    noise
    precisionFlag
    offset
    ready
  end
  
  methods (Access = public, Static = true)
    function this = GpsSim(initialTime, uri)
      this = this@antbed.GPSReceiver(initialTime);
      
      if(~strncmp(uri, 'antbed:', 7))
        error('URI scheme not recognized');
      end
      container = antbed.DataContainer.create(uri(8:end), initialTime);

      if(hasReferenceTrajectory(container))
         this.refTraj = getReferenceTrajectory(container);
      else
         this.refTraj = tom.DynamicModelDefault(initialTime, uri);
      end
           
      % Read the noise errors from real Global Sat GPS data file
      this.noise = readNoiseData(this.rawGPSfile); % (time, easting, northing, altitude)
      interval = this.refTraj.domain();
      tdelta = interval.second-interval.first;
      this.noise = this.noise(:, this.noise(1, :)<tdelta);
      this.precisionFlag = true;
      this.offset = [0; 0; 0];
      N = size(this.noise, 2);
      this.na = uint32(1);
      this.nb = uint32(N);
      this.ready = logical(N>0);
    end
  end
  
  methods (Access = public)  
    function refresh(this, x)
      assert(isa(this, 'antbed.GPSReceiver'));
      assert(isa(x, 'tom.Trajectory'));
    end
    
    function flag = hasData(this)
      flag = this.ready;
    end
    
    function na = first(this)
      assert(this.ready)
      na = this.na;
    end

    function nb = last(this)
      assert(this.ready)
      nb = this.nb;
    end
    
    function time = getTime(this, n)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      interval = this.refTraj.domain();
      time = tom.WorldTime(interval.first+this.noise(1, n));
    end

    function [lon, lat, alt] = getGlobalPosition(this, n)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      
      % Evaluate the reference trajectory at the measurement time
      pose = this.refTraj.evaluate(getTime(this, n));
      lolah = GlobalSatData.ecef2lolah(pose.p);
      
      % Add error based on real Global Sat gps data
      lon = lolah(1)+this.noise(2, n);
      lat = lolah(2)+this.noise(3, n);
      alt = lolah(3)+this.noise(4, n);
    end
    
    function flag = hasPrecision(this)
      flag = this.precisionFlag;
    end
    
    function [hDOP, vDOP, sigmaR] = getPrecision(this, n)
      assert(isa(n,'uint32'));
      hDOP = this.hDOP;
      vDOP = this.vDOP;
      sigmaR = this.sigmaR;
    end
    
    function offset = getAntennaOffset(this)
      offset = this.offset;
    end
  end
end

% Read a text file that contains an ascii GPS data stream
% Data is read from the line that begins with $GPGGA
%
% NOTES
% Refer to data formats at
% http://www.gpsinformation.org/dale/nmea.htm#GSA
function noise = readNoiseData(fname)
  currdir = fileparts(mfilename('fullpath'));
  full_fname = fullfile(currdir, fname);

  fid = fopen(full_fname, 'r');
  str = fgetl(fid);
  counter = 0;
  while str ~= -1
    if strmatch(str(1:6), '$GPGGA')

      counter = counter + 1;
      
      % collect all outputs from strread, then use those that are needed
      [strId, time, latstr, latDir, lonstr, lonDir, quality, numSat, precision, alt, mStr1, geoidalSep, mStr2, ...
        ageData, stationId] = strread(str,'%s %s %s %s %s %s %d %d %f %f %s %f %s %f %s', 'delimiter', ',');

      [lond,latd] = ll_string2deg(latstr, lonstr);

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

  noise = zeros(4, counter);
  noise(1, :) = T(:) - T(1);
  noise(2, :) = A(:) - mean(A);
  noise(3, :) = B(:) - mean(B);
  noise(4, :) = C(:) - mean(C);
end

% INPUTS
% lat = string of the form ddmm.mmmm
% long = string of the form dddmm.mmmm
function [lat_dec, long_dec] = ll_string2deg(lat, long)
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
