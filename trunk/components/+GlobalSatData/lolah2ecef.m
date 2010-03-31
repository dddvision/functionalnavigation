% Convert [Longitude, Latitude, Altitude] coordinates to Earth-Centered
% Earth-Fixed (ECEF) coordinates
% 
% Usage: [x, y, z] = lolah2ecef(lon, lat, alt)
%
% Inputs:
%   lon = longitude in radians
%   lat = latitude in radians
%   alt = height above WGS84 ellipsoid in meters
%
% Outputs:
%   [x,y,z]  = ECEF coordinates
%   
% Ref: http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf
%      Retrieved 11/30/2009
function [x, y, z] = lolah2ecef(lon, lat, alt)
  a = 6378137;
  finv = 298.257223563;
  b = a-a/finv;
  a2 = a.*a;
  b2 = b.*b;
  e = sqrt((a2-b2)./a2);
  slat = sin(lat);
  clat = cos(lat);
  N = a./sqrt(1-(e*e)*(slat.*slat));
  x = (alt+N).*clat.*cos(lon);
  y = (alt+N).*clat.*sin(lon);
  z = ((b2./a2)*N+alt).*slat;
end
