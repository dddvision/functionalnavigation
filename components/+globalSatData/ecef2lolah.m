function [lon, lat, alt] = ecef2lolah(x, y, z)

% Convert Earth-Centered Earth-Fixed (ECEF) coordinates to 
% [Longitude, Latitude, Altitude] coordinates 
% 
% Usage: [lon, lat, alt] = ecef2lolah(x, y, z)
%
% Inputs:
%   [x,y,z]  = ECEF coordinates
%
% Outputs
%   lon = longitude in radians
%   lat = latitude in radians
%   alt = height above WGS84 ellipsoid in meters
%   
% Ref: http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf
%      Retrieved 11/30/2009

% WGS84 parameters
a = 6378137;
b = 6356752.3142;

e = sqrt((a.^2-b.^2)./a.^2);
e_prime = sqrt((a.^2-b.^2)./b.^2);


p = sqrt(x.^2+y.^2);

theta = atan((z*a)./(p*b));

lon = atan(y./x);
lat = atan((z+e_prime^2*b*(sin(theta).^3))./ ...
           (p-e^2*a*(cos(theta).^3)));
% Compute prime vertical of curvature (meters)
N = a./sqrt(1-e.^2*(sin(lat).^2));
       
alt = p./cos(lat) - N;