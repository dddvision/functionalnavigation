% For each valid index in the GPS data domain, evaluate the reference
%   trajectory and compare with the reported GPS position
classdef GPSReceiverTest

  methods (Access = public, Static = true)
    function this = GPSReceiverTest(gpsHandle, trajectory)
      assert(isa(gpsHandle, 'antbed.GPSReceiver'));
      if(~gpsHandle.hasData())
        return;
      end

      na = gpsHandle.first();
      nb = gpsHandle.last();
      assert(isa(na, 'uint32'));
      assert(isa(nb, 'uint32'));

      K = 1+nb-na;
      gpsLonLatAlt = zeros(3, K);
      trueECEF = zeros(3, K);
      for indx = 1:K
        currTime = gpsHandle.getTime(indx);
        pose = trajectory.evaluate(currTime);
        trueECEF(:, indx) = cat(2, pose.p);
        [gpsLonLatAlt(1, indx), gpsLonLatAlt(2, indx), gpsLonLatAlt(3, indx)] = gpsHandle.getGlobalPosition(na+indx-1);
      end
      trueLonLatAlt = ecef2lolah(trueECEF);
      errLonLatAlt = gpsLonLatAlt-trueLonLatAlt;

      figure;
      hist(errLonLatAlt(1, :));
      title('GPS error (longitude)');

      figure;
      hist(errLonLatAlt(2, :));
      title('GPS error (latitude)');

      figure;
      hist(errLonLatAlt(3, :));
      title('GPS error (altitude)');

      figure;
      gpsECEF = lolah2ecef(gpsLonLatAlt);
      errECEF = gpsECEF-trueECEF;
      Raxes = [0, 0, -1;0, 1, 0;1, 0, 0];
      R = Euler2Matrix([0;-trueLonLatAlt(2, 1);trueLonLatAlt(1, 1)])*Raxes;
      errNED = R*errECEF;
      plot3(errNED(1, :), errNED(2, :), errNED(3, :), 'b.');
      title('GPS error (scatter plot)');
      xlabel('north (meters)');
      ylabel('east (meters)');
      zlabel('down (meters)');
      axis('equal');
      drawnow;
    end
  end
  
end

% Converts rotation from Euler to matrix form
function M = Euler2Matrix(Y)
  Y1 = Y(1);
  Y2 = Y(2);
  Y3 = Y(3);
  c1 = cos(Y1);
  c2 = cos(Y2);
  c3 = cos(Y3);
  s1 = sin(Y1);
  s2 = sin(Y2);
  s3 = sin(Y3);
  M = zeros(3);
  M(1, 1) = c3.*c2;
  M(1, 2) = c3.*s2.*s1-s3.*c1;
  M(1, 3) = s3.*s1+c3.*s2.*c1;
  M(2, 1) = s3.*c2;
  M(2, 2) = c3.*c1+s3.*s2.*s1;
  M(2, 3) = s3.*s2.*c1-c3.*s1;
  M(3, 1) = -s2;
  M(3, 2) = c2.*s1;
  M(3, 3) = c2.*c1;
end

% Convert from Longitude Latitude Height to Earth Centered Earth Fixed coordinates
%
% @param[in]  lolah position in longitude, latitude and height, radians and meters, (MATLAB: 3-by-N)
% @param[out] ecef  position in Earth Centered Earth Fixed coordinates, meters, (MATLAB: 3-by-N)
%
% NOTES
% http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf
%   Retrieved 11/30/2009
function ecef = lolah2ecef(lolah)
  lon = lolah(1, :);
  lat = lolah(2, :);
  alt = lolah(3, :);
  a = 6378137;
  finv = 298.257223563;
  b = a-a/finv;
  a2 = a.*a;
  b2 = b.*b;
  e = sqrt((a2-b2)./a2);
  slat = sin(lat);
  clat = cos(lat);
  N = a./sqrt(1-(e*e)*(slat.*slat));
  ecef = [(alt+N).*clat.*cos(lon);
          (alt+N).*clat.*sin(lon);
          ((b2./a2)*N+alt).*slat];
end

% Converts Earth Centered Earth Fixed coordinates to Longitude Latitude Height
%
% INPUT
% ecef = points in ECEF coordinates, 3-by-N
%
% OUTPUT
% lolah = converted points, 3-by-N
%   lolah(1, :) = longitude in radians
%   lolah(2, :) = geodetic (not geocentric) latitude in radians
%   lolah(3, :) = height above the WGS84 Earth ellipsoid in meters
%
% NOTES
% Using an Earth Centered Earth Fixed (ECEF) frame convention:
%   Axis 1 goes through the equator at the prime meridian
%   Axis 2 completes the frame using the right-hand-rule
%   Axis 3 goes through the north pole
% J. Zhu, "Conversion of Earth-centered Earth-fixed coordinates to geodetic
%   coordinates," Aerospace and Electronic Systems, vol. 30, pp. 957-961, 1994.
function lolah = ecef2lolah(ecef)
  X = ecef(1, :);
  Y = ecef(2, :);
  Z = ecef(3, :);
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
  s = ( 1+c+sqrt(c.*c+2*c) ).^(1/3);
  P = F./(3*(s+1./s+1).^2.*G.*G);
  Q = sqrt(1+2*e2*e2*P);
  ro = -(e2*P.*r)./(1+Q)+sqrt((a*a/2)*(1+1./Q)-((1-e2)*P.*Z.^2)./(Q.*(1+Q))-P.*r2/2);
  tmp = (r-e2*ro).^2;
  U = sqrt(tmp+Z.^2);
  V = sqrt(tmp+(1-e2)*Z.^2);
  zo = (b^2*Z)./(a*V);
  lolah = [atan2(Y, X); atan2(Z+ep2*zo, r); U.*(1-b^2./(a*V))];
end
