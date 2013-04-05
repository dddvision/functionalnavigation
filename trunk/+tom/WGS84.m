classdef WGS84
  properties (Constant = true, GetAccess = public)
    majorRadius = 6378137.0; % meters
    rotationRate = 7.2921151467e-5; % rad/sec
    gm = 3.986005E14; % meters^3/sec^2
    flattening = 1.0/298.257223563; % unitless
    inverseFlattening = 298.257223563; % unitless
    c20 = -4.84166E-4; % unitless (combined sources)
    minorRadius = tom.WGS84.majorRadius-tom.WGS84.majorRadius/tom.WGS84.inverseFlattening; % meters (Implementation Manual)
  end
  
  methods (Access = public, Static = true)
    function [gN, gE, gD] = gravityNED(N, E, D, gamma)
      % precalculations
      lambda = tom.WGS84.geodeticToGeocentric(gamma);
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

    function [x, y, z] = llaToECEF(lon, lat, alt)
      if(nargin==1)
        alt = lon(3, :);
        lat = lon(2, :);
        lon = lon(1, :);
      end
      a = tom.WGS84.majorRadius;
      finv = tom.WGS84.inverseFlattening;
      b = a-a/finv;
      a2 = a.*a;
      b2 = b.*b;
      e = sqrt((a2-b2)./a2);
      slat = sin(lat);
      clat = cos(lat);
      N = a./sqrt(1.0-(e*e)*(slat.*slat));
      x = (N+alt).*clat.*cos(lon);
      y = (N+alt).*clat.*sin(lon);
      z = ((b2./a2)*N+alt).*slat;
      if(nargout<=1)
        x = shiftdim(reshape(cat(1, x(:), y(:), z(:)), numel(x), 3), 1);
      end
    end

    function [lon, lat, alt] = ecefToLLA(x, y, z)
      if(nargin==1)
        z = x(3, :);
        y = x(2, :);
        x = x(1, :);
      end
      a = tom.WGS84.majorRadius;
      finv = tom.WGS84.inverseFlattening;
      f = 1.0/finv;
      b = a-a/finv;
      e2 = 2.0*f-f*f;
      ep2 = f*(2.0-f)/((1.0-f)*(1.0-f));
      r2 = x.*x+y.*y;
      r = sqrt(r2);
      E2 = a*a-b*b;
      F = 54.0*b*b*z.*z;
      G = r2+(1.0-e2)*z.*z-e2*E2;
      c = (e2*e2*F.*r2)./(G.*G.*G);
      s = power(1.0+c+sqrt(c.*c+2.0*c), 1.0/3.0);
      P = F./(3.0*power(s+1./s+1, 2.0).*G.*G);
      Q = sqrt(1.0+2.0*e2*e2*P);
      ro = -(e2*P.*r)./(1.0+Q)+sqrt((a*a/2.0)*(1.0+1.0./Q)-((1.0-e2)*P.*z.*z)./(Q.*(1.0+Q))-P.*r2/2.0);
      tmp = power(r-e2*ro, 2.0);
      U = sqrt(tmp+z.*z);
      V = sqrt(tmp+(1.0-e2)*z.*z);
      zo = (b*b*z)./(a*V);
      lon = atan2(y, x);
      lat = atan2(z+ep2*zo, r);
      alt = U.*(1.0-b*b./(a*V));
      if(nargout<=1)
        lon = shiftdim(reshape(cat(1, lon(:), lat(:), alt(:)), numel(lon), 3), 1);
      end
    end
    
    function gamma = geocentricToGeodetic(lambda)
      if(isnumeric(lambda))
        if(any((lambda<-pi/2)||(lambda>pi/2)))
          gamma = nan;
        else
          A = tom.WGS84.majorRadius/tom.WGS84.minorRadius;
          gamma = atan2((A*A)*sin(lambda), cos(lambda));
        end
      else
        syms re rp
        gamma = atan((re/rp)^2*sin(lambda)/cos(lambda));
      end
    end
    
    function lambda = geodeticToGeocentric(gamma)
      if(isnumeric(gamma))
        if(any((gamma<-pi/2)||(gamma>pi/2)))
          lambda = nan;
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
      lambda = tom.WGS84.geodeticToGeocentric(gamma);
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
      lambda = tom.WGS84.geodeticToGeocentric(gamma);
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
