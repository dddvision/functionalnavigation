function [x, y, z] = lolah2ecef(lon, lat, alt)

% Ref: http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf
%      Retrieved 11/30/2009
% Note that lon and lat are in radians
% alt is the height above the WGS ellipsoid

% WGS84 parameters
a = 6378137;
b = 6356752.3142;

e = sqrt((a.^2-b.^2)./a.^2);

% Compute prime vertical of curvature (meters)
N = a./sqrt(1-e.^2*(sin(lat).^2));

x = (alt+N).*cos(lat).*cos(lon);
y = (alt+N).*cos(lat).*sin(lon);

z = ((b.^2./a.^2)*N + alt).*sin(lat);