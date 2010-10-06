% Converts ECEF coordinates to longitude, latitude, height
%
% INPUT
% X = ECEF coordinate along Axis 1, 1-by-N
% Y = ECEF coordinate along Axis 2, 1-by-N
% Z = ECEF coordinate along Axis 3, 1-by-N
%
% OUTPUT
% lon = longitude in radians, 1-by-N
% lat = geodetic (not geocentric) latitude in radians, 1-by-N
% alt = height above the WGS84 Earth ellipsoid in meters, 1-by-N
%
% NOTES
% Using an Earth Centered Earth Fixed (ECEF) frame convention:
%   Axis 1 goes through the equator at the prime meridian
%   Axis 2 completes the frame using the right-hand-rule
%   Axis 3 goes through the north pole
% J. Zhu, "Conversion of Earth-centered Earth-fixed coordinates to geodetic
% coordinates," Aerospace and Electronic Systems, vol. 30, pp. 957-961, 1994.
function [lon, lat, alt] = ecef2lolah(X, Y, Z)
  a = 6378137.0;
  finv = 298.257223563;
  f = 1/finv;
  b = a-a/finv;
  e2 = 2*f-f^2;
  ep2 = f*(2-f)/((1-f)^2);
  r2 = X.^2+Y.^2;
  r = sqrt(r2);
  E2 = a^2-b^2;
  F = 54*b^2*Z.^2;
  G = r2+(1-e2)*Z.^2-e2*E2;
  c = (e2*e2*F.*r2)./(G.*G.*G);
  s = (1+c+sqrt(c.*c+2*c)).^(1/3);
  P = F./(3*(s+1./s+1).^2.*G.*G);
  Q = sqrt(1+2*e2*e2*P);
  ro = -(e2*P.*r)./(1+Q)+sqrt((a*a/2)*(1+1./Q)-((1-e2)*P.*Z.^2)./(Q.*(1+Q))-P.*r2/2);
  tmp = (r-e2*ro).^2;
  U = sqrt(tmp+Z.^2);
  V = sqrt(tmp+(1-e2)*Z.^2);
  zo = (b^2*Z)./(a*V);
  lon = atan2(Y,X);
  lat = atan((Z+ep2*zo)./r);
  alt = U.*(1-b^2./(a*V));
end
