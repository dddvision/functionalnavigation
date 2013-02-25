classdef WGS84
  properties (Constant = true, GetAccess = public)
    majorRadius = 6378137.0; % meters
    rotationRate = 7.292115E-5; % rad/sec
    gm = 3.986005E14; % meters^3/sec^2
    flattening = 1.0/298.257223563; % unitless
    inverseFlattening = 298.257223563; % unitless
    c20 = -4.84166E-4; % unitless (combined sources)
    minorRadius = tom.WGS84.majorRadius-tom.WGS84.majorRadius/tom.WGS84.inverseFlattening; % meters (Implementation Manual)
  end
  
  methods (Access = public, Static = true)
    function [gN, gE, gD] = gravityNED(N, E, D, gamma)
      % precalculations
      lambda = tom.WGS84.geodetic2Geocentric(gamma);
      r = tom.WGS84.geocentricRadius(lambda);
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

%     function [gN, gE, gD] = gravityNED2(N, E, D, gamma)
%       % coefficients
%       g0 = 9.78039; % meter/sec^2 adjusted value replaces 9.78049
%       g1 = 1.33e-8; % 1/sec^2
%       g2 = 5.2884e-3; % dimensionless
%       g3 = -5.9e-6; % dimensionless
%       g4 = -3.0877e-6; % 1/sec^2
%       g5 = 4.5e-8; % 1/sec^2
%       g6 = 7.2e-13; % 1/(meter*sec^2)  
% 
%       % precalculations
%       lambda = tom.WGS84.geodetic2Geocentric(gamma);
%       r = tom.WGS84.geocentricRadius(lambda);
%       sgam = sin(gamma);
%       cgam = cos(gamma);
%       slam = sin(lambda);
%       clam = cos(lambda);
% 
%       % position relative to the 3-D ellipsoid in Earth-centered frame
%       X = r*clam-sgam*N-cgam*D;
%       Y = E;
%       Z = r*slam+cgam*N-sgam*D;
% 
%       % relative longitude
%       theta = atan2(Y, X);
%       sth = sin(theta);
%       cth = cos(theta);
% 
%       XY = sqrt(X.*X+Y.*Y);
%       R = sqrt(X.*X+Y.*Y+Z.*Z);
% 
%       % instantaneous latitude
%       lam = atan2(Z,XY);
%       gam = tom.WGS84.geocentric2Geodetic(lam);
% 
%       % instantaneous height
%       h = R-tom.WGS84.geocentricRadius(lam);
% 
%       % precalculations
%       clat = cos(gam);
%       slat = sin(gam);
%       slat2 = slat.*slat;
%       s2lat = sin(2*gam);
%       s2lat2 = s2lat.*s2lat;
% 
%       % gravity model
%       gNp = g1*h.*s2lat;
%       gDp = g0*(1.0+g2*slat2+g3*s2lat2)+(g4+g5*slat2).*h+g6*h.*h;
% 
%       gZ  =  clat.*gNp-slat.*gDp;
%       gXY = -slat.*gNp-clat.*gDp-(tom.WGS84.rotationRate*tom.WGS84.rotationRate*100000)*(XY./100000);
% 
%       gX = gXY.*cth;
%       gY = gXY.*sth;
% 
%       % gravity viewed in NED frame
%       gN = -slat.*gX+clat.*gZ;
%       gE = gY;
%       gD = -clat.*gX-slat.*gZ;
%     end

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
      gXY = gR*clam-gT*slam;
      gX = gXY.*cth;
      gY = gXY.*sth;
      gZ  = gR*slam+gT*clam;
    end

    function [X, Y, Z] = llaToECEF(lon, lat, alt)
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

%     function [X, Y, Z] = llaToECEF(lon, lat, alt)
%       re = tom.WGS84.majorRadius;
%       finv = tom.WGS84.inverseFlattening;
%       rp = re-re/finv;
%       clon = cos(lon);
%       slon = sin(lon);
%       clat = cos(lat);
%       slat = sin(lat);
%       ratio = rp/re;
%       lambda = atan2(ratio*ratio*slat, clat);
%       A = re*sin(lambda);
%       B = rp*cos(lambda);
%       r = (re*rp)./sqrt(A.*A+B.*B);
%       clambda = cos(lambda);
%       slambda = sin(lambda);
%       surface = [r.*clon.*clambda; r.*slon.*clambda; r.*slambda];
%       above = [alt.*clon.*clat; alt.*slon.*clat; alt.*slat];
%       ecef = surface+above;
%       X = ecef(1, :);
%       Y = ecef(2, :);
%       Z = ecef(3, :);
%     end

    function [lon, lat, alt] = ecefToLLA(X, Y, Z)
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
    
    function gamma = geocentric2Geodetic(lambda)
      if(isnumeric(lambda))
        if(any((lambda<-pi/2)||(lambda>pi/2)))
          gamma = NaN;
        else
          A = tom.WGS84.majorRadius/tom.WGS84.minorRadius;
          gamma = atan2((A*A)*sin(lambda), cos(lambda));
        end
      else
        syms re rp
        gamma = atan((re/rp)^2*sin(lambda)/cos(lambda));
      end
    end
    
    function lambda = geodetic2Geocentric(gamma)
      if(isnumeric(gamma))
        if(any((gamma<-pi/2)||(gamma>pi/2)))
          lambda = NaN;
        else
          lambda = atan2((tom.WGS84.minorRadius/tom.WGS84.majorRadius)^2*sin(gamma), cos(gamma));
        end
      else
        syms re rp
        lambda = atan((rp/re)^2*sin(gamma)/cos(gamma));
      end
    end

    function radius = geocentricRadius(lambda)
      A = tom.WGS84.majorRadius*sin(lambda);
      B = tom.WGS84.minorRadius*cos(lambda);
      radius = (tom.WGS84.majorRadius*tom.WGS84.minorRadius)./sqrt(A.*A+B.*B);
    end
    
    function radius = geodeticRadius(gamma)
      lambda = tom.WGS84.geodetic2Geocentric(gamma);
      A = tom.WGS84.majorRadius*sin(lambda);
      B = tom.WGS84.minorRadius*cos(lambda);
      radius = (tom.WGS84.majorRadius*tom.WGS84.minorRadius)./sqrt(A.*A+B.*B);
    end
    
    function [OmegaNED, XddNED] = rotationEffectNED(X_rel, Xdav_rel, gamma)
      [m,na]=size(X_rel);
      if m~=3
        error('Relative position argument must be 3-by-(n+1)');
      end

      [m,nb]=size(Xdav_rel);
      if m~=3
        error('Relative velocity argument must be 3-by-n');
      end

      if (na~=nb)
        error('The number of position samples must equal the number of velocity samples');
      end
      N=na;

      % constants
      re = tom.WGS84.minorRadius;
      rp = tom.WGS84.majorRadius;
      omega = tom.WGS84.rotationRate;
      lambda = tom.WGS84.geodetic2Geocentric(gamma);
      rs = EllipticalRadius(re, rp, lambda);
      sgam = sin(gamma);
      cgam = cos(gamma);
      omega2 = omega^2;

      % seperating the data
      x1 = X_rel(1, :);
      x2 = X_rel(2, :);
      x3 = X_rel(3, :);

      xd1 = Xdav_rel(1, :);
      xd2 = Xdav_rel(2, :);
      xd3 = Xdav_rel(3, :);

      % velocity equation
      % Nd = xd1+omega*sgam*x2;
      % Ed = xd2-omega*sgam*x1-omega*cgam*x3+omega*r*cgam;
      % Dd = xd3+omega*cgam*x2;
      % XdNED = [Nd; Ed; Dd];

      % rotation rate equation
      ON = omega*cgam*ones(1, N);
      OE = zeros(1, N);
      OD = -omega*sgam*ones(1, N);
      OmegaNED = [ON; OE; OD];

      % acceleration equation
      Ndd = 2*omega*sgam*xd2-omega2*sgam^2*x1-omega2*sgam*cgam*x3+omega2*rs*cgam*sgam;
      Edd = -2*omega*sgam*xd1-2*omega*cgam*xd3-omega2*x2;
      Ddd = 2*omega*cgam*xd2-omega2*sgam*cgam*x1-omega2*cgam^2*x3+omega2*rs*cgam^2;
      XddNED = [Ndd; Edd; Ddd];
    end
  end
end
