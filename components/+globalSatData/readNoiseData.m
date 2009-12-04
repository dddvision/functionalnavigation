function xyzErrors=readNoiseData(fname)
% Read a text file that contains an ascii GPS data stream
% Data is read from the line that begins with $GPGGA
%
% Refer to data formats at http://www.gpsinformation.org/dale/nmea.htm#GSA

maindir = pwd;
currdir = [maindir '/components/+globalSatData'];
full_fname = fullfile(currdir, fname);

fid = fopen(full_fname,'r');
counter = 0;

str = fgetl(fid);

while str ~= -1
  if strmatch(str(1:6), '$GPGGA')
    
    counter = counter + 1;
    [strId, time, lat, latDir, long, longDir, quality, numSat, ...
      precision, antennaAltitude,mStr1,geoidalSep, mStr2, ...
      ageData, stationId] = ...
      strread(str,'%s %s %s %s %s %s %d %d %f %f %s %f %s %f %s', ...
      'delimiter',',');
    gpsTime(counter) = time;
    latDir = latDir;
    longDir = longDir;
    
    [long, lat] = ll_string2deg(lat,long);
    
    if strmatch(latDir, 'W')
      lat = -lat;
    end
    
    if strmatch(longDir, 'S');
      long = -long;
    end
    alt(counter) = antennaAltitude;
    [X(counter), Y(counter), Z(counter)] = ...
      globalSatData.lolah2ecef((pi/180)*long, (pi/180)*lat, antennaAltitude);
    
  end
  
  str = fgetl(fid);
  
end
fclose(fid);

xyzErrors(:,1) = X -mean(X);
xyzErrors(:,2) = Y -mean(Y);
xyzErrors(:,3) = Z - mean(Z);


end

function [lat_dec, long_dec] = ll_string2deg(lat, long)

% Input lat long are strings of the form ddmm.mmmm
% for lat and dddmm.mmmm for long
lat = char(lat);
long = char(long);
lat_dec = str2double(lat(1:2)) + str2double(lat(3:end))./60;
long_dec = str2double(long(1:3)) + str2double(long(4:end))./60;

end

function [lat_str, long_str] = ll_deg2string(lat, long)

lat_min = mod(lat,1)*60;
lat_str = sprintf('%02d%07.4f', floor(lat), lat_min);

long_min = mod(long,1)*60;
long_str = sprintf('%03d%07.4f', floor(long), long_min);

end