% WGS84 Ellipsoidal Earth model.
%
% @note
% WGS84 Implementation Manual, v.2.4, 1998.
% WGS84: It's definition and relationship to Local Geodetic Systems. NIMA Technical Report, 3rd ed. 2000.
% Earth Centered Earth Fixed (ECEF) frame convention:
%   Axis 1 goes through the equator at the prime meridian
%   Axis 2 completes the frame using the right-hand-rule
%   Axis 3 goes through the north pole
classdef WGS84
  properties (Constant = true, GetAccess = public)
    % primary source values
    majorRadius = 6378137.0; % meters
    rotationRate = 7.292115E-5; % rad/sec
    gm = 3.986005E14; % meters^3/sec^2
    flattening = 1.0/298.257223563; % unitless
    % surfacePotential = 62636851.7146; % meters^2/sec^2

    % derived values
    inverseFlattening = 298.257223563; % unitless
    c20 = -4.84166E-4; % unitless (combined sources)
    minorRadius = tom.WGS84.majorRadius-tom.WGS84.majorRadius/tom.WGS84.inverseFlattening; % meters (Implementation Manual)
    % polarGravity = -9.8321849378; % meters/sec^2 (NIMA)
    % polarGravity = -9.8322131433; % meters/sec^2 (Draper)
    % equatorialGravity = -9.7803253359-(tom.WGS84.rotationRate*tom.WGS84.rotationRate*1000000)*(tom.WGS84.majorRadius/1000000); % meters/sec^2 (combined sources)
    % equatorialGravity = -9.78049-(tom.WGS84.rotationRate*tom.WGS84.rotationRate*1000000)*(tom.WGS84.majorRadius/1000000); % meters/sec^2 (Draper)
    % equatorialGravity = -9.8144057073; % meters/sec^2 (Draper)
  end
  
  methods (Access = public, Static = true)
    % Ellipsoidal 1/r falloff gravity potential model in local North-East-Down frame.
    % 
    % @param[in]  N     North coordinate in meters
    % @param[in]  E     East coordinate in meters
    % @param[in]  D     Down coordinate in meters
    % @param[in]  gamma Geodetic latitude that defines the NED frame origin in radians
    % @param[out] gN    Gravity component in the north direction
    % @param[out] gE    Gravity component in the east direction
    % @param[out] gD    Gravity component in the down direction
    function [gN, gE, gD] = gravityNED(N, E, D, gamma)
      lambda = tom.WGS84.geodetic2Geocentric(gamma);
      r = tom.WGS84.geocentricRadius(lambda);

      % precalculations
      sgam = sin(gamma);
      cgam = cos(gamma);
      slam = sin(lambda);
      clam = cos(lambda);

      % position relative to the 3-D ellipsoid in Earth-centered frame
      X = r*clam-sgam*N-cgam*D;
      Y = E;
      Z = r*slam+cgam*N-sgam*D;

      % relative longitude
      theta = atan2(Y, X);
      sth = sin(theta);
      cth = cos(theta);

      % gradient of the potential around the 2-D ellipse model   
      R2 = X.*X+Y.*Y+Z.*Z;
      XY = sqrt(X.*X+Y.*Y);

      gmR2  = (tom.WGS84.gm./R2);
      re2R2 = ((tom.WGS84.majorRadius*tom.WGS84.majorRadius)./R2);

      gR = -gmR2.*(1.0+(9.0/2.0*sqrt(5.0)*tom.WGS84.c20)*re2R2.*(Z.*Z./R2-1.0/3.0));
      gT = (3.0*sqrt(5.0)*tom.WGS84.c20)*gmR2.*re2R2.*(XY.*Z./R2);

      % gravity viewed in ECEF frame
      gZ  = gR*slam+gT*clam;
      gXY = gR*clam-gT*slam;

      gX = gXY.*cth;
      gY = gXY.*sth;

      % gravity viewed in NED frame
      gN = -sgam*gX+cgam*gZ;
      gE = gY;
      gD = -cgam*gX-sgam*gZ;
    end
    
    % Near-Earth gravity model in local North-East-Down frame.
    % 
    % @param[in]  N     North coordinate in meters
    % @param[in]  E     East coordinate in meters
    % @param[in]  D     Down coordinate in meters
    % @param[in]  gamma Geodetic latitude that defines the NED frame origin in radians
    % @param[out] gN    Gravity component in the north direction
    % @param[out] gE    Gravity component in the east direction
    % @param[out] gD    Gravity component in the down direction
    function [gN, gE, gD] = gravityNED2(N, E, D, gamma)
      lambda = tom.WGS84.geodetic2Geocentric(gamma);
      r = tom.WGS84.geocentricRadius(lambda);

      % precalculations
      sgam = sin(gamma);
      cgam = cos(gamma);
      slam = sin(lambda);
      clam = cos(lambda);

      % position relative to the 3-D ellipsoid in Earth-centered frame
      X = r*clam-sgam*N-cgam*D;
      Y = E;
      Z = r*slam+cgam*N-sgam*D;

      % relative longitude
      theta = atan2(Y, X);
      sth = sin(theta);
      cth = cos(theta);

      XY = sqrt(X.*X+Y.*Y);
      R = sqrt(X.*X+Y.*Y+Z.*Z);

      % coefficients
      g0 = 9.78039; %meter/sec^2 adjusted value replaces 9.78049
      g1 = 1.33e-8; %1/sec^2
      g2 = 5.2884e-3; % dimensionless
      g3 = -5.9e-6; % dimensionless
      g4 = -3.0877e-6; % 1/sec^2
      g5 = 4.5e-8; % 1/sec^2
      g6 = 7.2e-13; % 1/(meter*sec^2)  

      % instantaneous latitude
      lam = atan2(Z,XY);
      gam = tom.WGS84.geocentric2Geodetic(lam);

      % instantaneous height
      h = R-tom.WGS84.geocentricRadius(lam);

      % precalculations
      clat = cos(gam);
      slat = sin(gam);
      slat2 = slat.*slat;
      s2lat = sin(2*gam);
      s2lat2 = s2lat.*s2lat;

      % gravity model
      gNp = g1*h.*s2lat;
      gDp = g0*(1.0+g2*slat2+g3*s2lat2)+(g4+g5*slat2).*h+g6*h.*h;

      gZ  =  clat.*gNp-slat.*gDp;
      gXY = -slat.*gNp-clat.*gDp-(tom.WGS84.rotationRate*tom.WGS84.rotationRate*100000)*(XY./100000);

      gX = gXY.*cth;
      gY = gXY.*sth;

      % gravity viewed in NED frame
      gN = -slat.*gX+clat.*gZ;
      gE = gY;
      gD = -clat.*gX-slat.*gZ;
    end
    
    % Ellipsoidal 1/r falloff gravity potential model in Earth-Centered-Earth-Fixed frame.
    % 
    % @param[in]  X  First coordinate in meters
    % @param[in]  Y  Second coordinate in meters
    % @param[in]  Z  Third coordinate in meters
    % @param[out] gX Gravity component in the first direction
    % @param[out] gY Gravity component in the second direction
    % @param[out] gZ Gravity component in the third direction
    function [gX, gY, gZ] = gravityECEF(X, Y, Z)   
      % relative longitude
      theta = atan2(Y, X);
      sth = sin(theta);
      cth = cos(theta);

      % gradient of the potential around the 2-D ellipse model   
      R2 = X.*X+Y.*Y+Z.*Z;
      XY = sqrt(X.*X+Y.*Y);
      
      lambda = atan2(Z, XY);
      slam = sin(lambda);
      clam = cos(lambda);

      gmR2  = (tom.WGS84.gm./R2);
      re2R2 = ((tom.WGS84.majorRadius*tom.WGS84.majorRadius)./R2);

      gR = -gmR2.*(1.0+(9.0/2.0*sqrt(5.0)*tom.WGS84.c20)*re2R2.*(Z.*Z./R2-1.0/3.0));
      gT = (3.0*sqrt(5.0)*tom.WGS84.c20)*gmR2.*re2R2.*(XY.*Z./R2);

      % gravity viewed in ECEF frame
      gZ  = gR*slam+gT*clam;
      gXY = gR*clam-gT*slam;

      gX = gXY.*cth;
      gY = gXY.*sth;
    end
    
    % Converts from Longitude-Latitude-Height to Earth Centered Earth Fixed coordinates.
    %
    % @param[in]  lon Longitude in radians
    % @param[in]  lat Geodetic latitude in radians
    % @param[in]  alt Height in meters
    % @param[out] X   First coordinate in meters
    % @param[out] Y   Second coordinate in meters
    % @param[out] Z   Third coordinate in meters
    %
    % @note
    % http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf (Retrieved 11/30/2009)
    function [X, Y, Z] = lolah2ecef(lon, lat, alt)
      a = tom.WGS84.majorRadius;
      finv = tom.WGS84.inverseFlattening;
      b = a-a/finv;
      a2 = a.*a;
      b2 = b.*b;
      e = sqrt((a2-b2)./a2);
      slat = sin(lat);
      clat = cos(lat);
      N = a./sqrt(1-(e*e)*(slat.*slat));
      X = (alt+N).*clat.*cos(lon);
      Y = (alt+N).*clat.*sin(lon);
      Z = ((b2./a2)*N+alt).*slat;
    end

    % (DEPRECATED) Converts from Longitude-Latitude-Height to Earth Centered Earth Fixed coordinates.
    %
    % @param[in]  lon Longitude in radians
    % @param[in]  lat Geodetic latitude in radians
    % @param[in]  alt Height in meters
    % @param[out] X   First coordinate in meters
    % @param[out] Y   Second coordinate in meters
    % @param[out] Z   Third coordinate in meters
    function [X, Y, Z] = lolah2ecef2(lon, lat, alt)
      re = tom.WGS84.majorRadius;
      finv = tom.WGS84.inverseFlattening;
      rp = re-re/finv;
      clon = cos(lon);
      slon = sin(lon);
      clat = cos(lat);
      slat = sin(lat);
      ratio = rp/re;
      lambda = atan2(ratio*ratio*slat, clat);
      A = re*sin(lambda);
      B = rp*cos(lambda);
      r = (re*rp)./sqrt(A.*A+B.*B);
      clambda = cos(lambda);
      slambda = sin(lambda);
      surface = [r.*clon.*clambda; r.*slon.*clambda; r.*slambda];
      above = [alt.*clon.*clat; alt.*slon.*clat; alt.*slat];
      ecef = surface+above;
      X = ecef(1, :);
      Y = ecef(2, :);
      Z = ecef(3, :);
    end

    % Converts Earth Centered Earth Fixed coordinates to Longitude Latitude Height
    %
    % INPUT
    % @param[in]  X   First coordinate in meters
    % @param[in]  Y   Second coordinate in meters
    % @param[in]  Z   Third coordinate in meters
    % @param[out] lon Longitude in radians
    % @param[out] lat Geodetic latitude in radians
    % @param[out] alt Height above the Earth ellipsoid in meters
    %
    % NOTES
    % J. Zhu, "Conversion of Earth-centered Earth-fixed coordinates to geodetic coordinates," Aerospace and Electronic 
    %   Systems, vol. 30, pp. 957-961, 1994.
    function [lon, lat, alt] = ecef2lolah(X, Y, Z)
      a = tom.WGS84.majorRadius;
      finv = tom.WGS84.inverseFlattening;
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
      lon = atan2(Y, X);
      lat = atan2(Z+ep2*zo, r);
      alt = U.*(1-b^2./(a*V));
    end
    
    % Convert geocentric angle to geodetic angle.
    %
    % @param[in]  lambda geocentric latitude
    % @param[out] gamma  geodetic latitude
    function gamma = geocentric2Geodetic(lambda)
      if(isnumeric(lambda))
        if(any((lambda<-pi/2)||(lambda>pi/2)))
          error('Geocentric Earth Latitude must fall in the range [-pi/2 pi/2].');
        end
        A = tom.WGS84.majorRadius/tom.WGS84.minorRadius;
        gamma = atan2((A*A)*sin(lambda), cos(lambda));
      else
        syms re rp
        gamma = atan((re/rp)^2*sin(lambda)/cos(lambda));
      end
    end
    
    % Convert geodetic angle to geocentric angle.
    %
    % @param[in]  gamma  geodetic latitude
    % @param[out] lambda geocentric latitude
    function lambda = geodetic2Geocentric(gamma)
      if(isnumeric(gamma))
        if(any((gamma<-pi/2)||(gamma>pi/2)))
          error('Geodetic Earth latitude must fall in the range [-pi/2 pi/2].');
        end
        lambda = atan2((tom.WGS84.minorRadius/tom.WGS84.majorRadius)^2*sin(gamma), cos(gamma));
      else
        syms re rp
        lambda = atan((rp/re)^2*sin(gamma)/cos(gamma));
      end
    end

    % Radius from center of ellipse to point on the ellipse at a geocentric angle from the major axis.
    % 
    % @param[in]  lambda Geocentric latitude in radians
    % @param[out] radius Radius in meters
    function radius = geocentricRadius(lambda)
      A = tom.WGS84.majorRadius*sin(lambda);
      B = tom.WGS84.minorRadius*cos(lambda);
      radius = (tom.WGS84.majorRadius*tom.WGS84.minorRadius)./sqrt(A.*A+B.*B);
    end
    
    % Radius from center of ellipse to point on the ellipse at a geodetic angle from the major axis.
    % 
    % @param[in]  gamma  Geodetic latitude in radians
    % @param[out] radius Radius in meters
    function radius = geodeticRadius(gamma)
      lambda = tom.WGS84.geodetic2Geocentric(gamma);
      A = tom.WGS84.majorRadius*sin(lambda);
      B = tom.WGS84.minorRadius*cos(lambda);
      radius = (tom.WGS84.majorRadius*tom.WGS84.minorRadius)./sqrt(A.*A+B.*B);
    end
  end
end
