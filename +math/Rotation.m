classdef Rotation 
  methods (Access = public, Static = true)
    function [y0, y1, y2] = axisToEuler(v0, v1, v2)
      if(nargin==1)
        v2 = v0(3, :);
        v1 = v0(2, :);
        v0 = v0(1, :);
      end
      [r00, r10, r20, r01, r11, r21, r02, r12, r22] = math.Rotation.axisToMatrix(v0, v1, v2);
      [y0, y1, y2] = math.Rotation.matrixToEuler(r00, r10, r20, r01, r11, r21, r02, r12, r22);
      if(nargout<=1)
        y0 = shiftdim(reshape(cat(1, y0(:), y1(:), y2(:)), numel(y0), 3), 1);
      end
    end
    
    function [r00, r10, r20, r01, r11, r21, r02, r12, r22] = axisToMatrix(v0, v1, v2)
      if(nargin==1)
        v2 = v0(3, :);
        v1 = v0(2, :);
        v0 = v0(1, :);
      end
      if(~isnumeric(v0))
        error('Rotation: The axis angle representation of rotation must be numeric.');
      end
      vNorm0 = v0;
      vNorm1 = v1;
      vNorm2 = v2;
      theta = sqrt(v0.*v0+v1.*v1+v2.*v2);
      c = cos(theta);
      s = sin(theta);
      a = 1.0-c;
      nonzero = find(theta>eps);
      vNorm0(nonzero) = vNorm0(nonzero)./theta(nonzero);
      vNorm1(nonzero) = vNorm1(nonzero)./theta(nonzero);
      vNorm2(nonzero) = vNorm2(nonzero)./theta(nonzero);
      r00 = a.*vNorm0.*vNorm0+c;
      r10 = a.*vNorm0.*vNorm1+s.*vNorm2;
      r20 = a.*vNorm0.*vNorm2-s.*vNorm1;
      r01 = a.*vNorm0.*vNorm1-s.*vNorm2;
      r11 = a.*vNorm1.*vNorm1+c;
      r21 = a.*vNorm1.*vNorm2+s.*vNorm0;     
      r02 = a.*vNorm0.*vNorm2+s.*vNorm1;
      r12 = a.*vNorm1.*vNorm2-s.*vNorm0;
      r22 = a.*vNorm2.*vNorm2+c;
      if(nargout<=1)
        r00 = shiftdim(reshape(cat(1, r00(:), r10(:), r20(:), r01(:), r11(:), r21(:), r02(:), r12(:), r22(:)), ...
          numel(r00), 3, 3), 1);
      end
    end

    function [q0, q1, q2, q3] = axisToQuat(v0, v1, v2)
      if(nargin==1)
        v2 = v0(3, :);
        v1 = v0(2, :);
        v0 = v0(1, :);
      end
      if(~isnumeric(v0))
        error('Rotation: The axis angle representation of rotation must be numeric.');
      end
      vNorm0 = v0;
      vNorm1 = v1;
      vNorm2 = v2;
      theta = sqrt(v0.*v0+v1.*v1+v2.*v2);
      theta2 = theta/2.0;
      c = cos(theta2);
      s = sin(theta2);
      nonzero = find(theta>eps);
      vNorm0(nonzero) = vNorm0(nonzero)./theta(nonzero);
      vNorm1(nonzero) = vNorm1(nonzero)./theta(nonzero);
      vNorm2(nonzero) = vNorm2(nonzero)./theta(nonzero);
      qRaw0 = c;
      qRaw1 = s.*vNorm0;
      qRaw2 = s.*vNorm1;
      qRaw3 = s.*vNorm2;
      [q0, q1, q2, q3] = math.Rotation.quatNorm(qRaw0, qRaw1, qRaw2, qRaw3);
      if(nargout<=1)
        q0 = shiftdim(reshape(cat(1, q0(:), q1(:), q2(:), q3(:)), numel(q0), 4), 1);
      end
    end
    
    function [v0, v1, v2] = eulerToAxis(y0, y1, y2)
      if(nargin==1)
        y2 = y0(3, :);
        y1 = y0(2, :);
        y0 = y0(1, :);
      end
      [q0, q1, q2, q3] = math.Rotation.eulerToQuat(y0, y1, y2);
      [v0, v1, v2] = math.Rotation.quatToAxis(q0, q1, q2, q3);
      if(nargout<=1)
        v0 = shiftdim(reshape(cat(1, v0(:), v1(:), v2(:)), numel(v0), 3), 1);
      end
    end
    
    function [r00, r10, r20, r01, r11, r21, r02, r12, r22] = eulerToMatrix(y0, y1, y2)
      if(nargin==1)
        y2 = y0(3, :);
        y1 = y0(2, :);
        y0 = y0(1, :);
      end
      c0 = cos(y0);
      c1 = cos(y1);
      c2 = cos(y2);
      s0 = sin(y0);
      s1 = sin(y1);
      s2 = sin(y2);
      r00 = c2.*c1;
      r10 = s2.*c1;      
      r20 = -s1;
      r01 = c2.*s1.*s0-s2.*c0;
      r11 = c2.*c0+s2.*s1.*s0;
      r21 = c1.*s0;      
      r02 = s2.*s0+c2.*s1.*c0;
      r12 = s2.*s1.*c0-c2.*s0;
      r22 = c1.*c0;
      if(nargout<=1)
        r00 = shiftdim(reshape(cat(1, r00(:), r10(:), r20(:), r01(:), r11(:), r21(:), r02(:), r12(:), r22(:)), ...
          numel(r00), 3, 3), 1);
      end
    end
    
    function [q0, q1, q2, q3] = eulerToQuat(y0, y1, y2)
      if(nargin==1)
        y2 = y0(3, :);
        y1 = y0(2, :);
        y0 = y0(1, :);
      end
      z0 = y0/2.0;
      z1 = y1/2.0;
      z2 = y2/2.0;      
      c0 = cos(z0);
      c1 = cos(z1);
      c2 = cos(z2);
      s0 = sin(z0);
      s1 = sin(z1);
      s2 = sin(z2);
      qRaw0 = c2.*c1.*c0+s2.*s1.*s0;
      qRaw1 = c2.*c1.*s0-s2.*s1.*c0;
      qRaw2 = c2.*s1.*c0+s2.*c1.*s0;
      qRaw3 = s2.*c1.*c0-c2.*s1.*s0;
      [q0, q1, q2, q3] = math.Rotation.quatNorm(qRaw0, qRaw1, qRaw2, qRaw3);
      if(nargout<=1)
        q0 = shiftdim(reshape(cat(1, q0(:), q1(:), q2(:), q3(:)), numel(q0), 4), 1);
      end
    end

    function [v0, v1, v2] = matrixToAxis(r00, r10, r20, r01, r11, r21, r02, r12, r22)
      if(nargin==1)
        r22 = r00(3, 3, :);
        r12 = r00(2, 3, :);
        r02 = r00(1, 3, :);
        r21 = r00(3, 2, :);
        r11 = r00(2, 2, :);
        r01 = r00(1, 2, :);
        r20 = r00(3, 1, :);
        r10 = r00(2, 1, :);
        r00 = r00(1, 1, :);
      end
      [q0, q1, q2, q3] = math.Rotation.matrixToQuat(r00, r10, r20, r01, r11, r21, r02, r12, r22);
      [v0, v1, v2] = math.Rotation.quatToAxis(q0, q1, q2, q3);
      if(nargout<=1)
        v0 = shiftdim(reshape(cat(1, v0(:), v1(:), v2(:)), numel(v0), 3), 1);
      end
    end
    
    function [y0, y1, y2] = matrixToEuler(r00, r10, r20, r01, r11, r21, r02, r12, r22)  %#ok unused
      if(nargin==1)
        r22 = r00(3, 3, :);
        % r12 = r00(2, 3, :);
        % r02 = r00(1, 3, :);
        r21 = r00(3, 2, :);
        % r11 = r00(2, 2, :);
        % r01 = r00(1, 2, :);
        r20 = r00(3, 1, :);
        r10 = r00(2, 1, :);
        r00 = r00(1, 1, :);
      end
      if(isnumeric(r00))
        y0 = atan2(r21, r22);
        y1 = asin(-r20);
        y2 = atan2(r10, r00);
      else
        y0 = atan(r21./r22);
        y1 = asin(-r20);
        y2 = atan(r10./r00);
      end
      if(nargout<=1)
        y0 = shiftdim(reshape(cat(1, y0(:), y1(:), y2(:)), numel(y0), 3), 1);
      end
    end
    
    function [q0, q1, q2, q3] = matrixToQuat(r00, r10, r20, r01, r11, r21, r02, r12, r22)
      if(nargin==1)
        r22 = r00(3, 3, :);
        r12 = r00(2, 3, :);
        r02 = r00(1, 3, :);
        r21 = r00(3, 2, :);
        r11 = r00(2, 2, :);
        r01 = r00(1, 2, :);
        r20 = r00(3, 1, :);
        r10 = r00(2, 1, :);
        r00 = r00(1, 1, :);
      end
      [y0, y1, y2] = math.Rotation.matrixToEuler(r00, r10, r20, r01, r11, r21, r02, r12, r22);
      [q0, q1, q2, q3] = math.Rotation.eulerToQuat(y0, y1, y2);
      if(nargout<=1)
        q0 = shiftdim(reshape(cat(1, q0(:), q1(:), q2(:), q3(:)), numel(q0), 4), 1);
      end
    end

    function [v0, v1, v2] = quatToAxis(q0, q1, q2, q3)
      if(nargin==1)
        q3 = q0(4, :);
        q2 = q0(3, :);
        q1 = q0(2, :);
        q0 = q0(1, :);
      end
      if(~isnumeric(q0))
        error('Rotation: The axis angle representation of rotation must be numeric.');
      end
      [qNorm0, qNorm1, qNorm2, qNorm3] = math.Rotation.quatNorm(q0, q1, q2, q3);
      n = sqrt(qNorm1.*qNorm1+qNorm2.*qNorm2+qNorm3.*qNorm3);
      nonzero = find(n>eps);
      qNorm1(nonzero) = qNorm1(nonzero)./n(nonzero);
      qNorm2(nonzero) = qNorm2(nonzero)./n(nonzero);
      qNorm3(nonzero) = qNorm3(nonzero)./n(nonzero);
      theta = 2.0*acos(qNorm0);
      v0 = theta.*qNorm1;
      v1 = theta.*qNorm2;
      v2 = theta.*qNorm3;
      if(nargout<=1)
        v0 = shiftdim(reshape(cat(1, v0(:), v1(:), v2(:)), numel(v0), 3), 1);
      end
    end
    
    function [y0, y1, y2] = quatToEuler(q0, q1, q2, q3)
      if(nargin==1)
        q3 = q0(4, :);
        q2 = q0(3, :);
        q1 = q0(2, :);
        q0 = q0(1, :);
      end
      [q0, q1, q2, q3] = math.Rotation.quatNorm(q0, q1, q2, q3);
      q00 = q0.*q0;
      q11 = q1.*q1;
      q22 = q2.*q2;
      q33 = q3.*q3;
      q01 = q0.*q1;
      q12 = q1.*q2;
      q23 = q2.*q3;
      q03 = q0.*q3;
      q02 = q0.*q2;
      q13 = q1.*q3;
      if(isnumeric(q0))
        y0 = atan2(2.0*(q23+q01), q00-q11-q22+q33);
        y1 = asin(min(max(-2.0*(q13-q02), -1.0), 1.0));
        y2 = atan2(2.0*(q12+q03), q00+q11-q22-q33);
      else
        y0 = atan((2.0*(q23+q01))./(q00-q11-q22+q33));
        y1 = asin(-2.0*(q13-q02));
        y2 = atan((2.0*(q12+q03))./(q00+q11-q22-q33));
      end
      if(nargout<=1)
        y0 = shiftdim(reshape(cat(1, y0(:), y1(:), y2(:)), numel(y0), 3), 1);
      end
    end
    
    function [r00, r10, r20, r01, r11, r21, r02, r12, r22] = quatToMatrix(q0, q1, q2, q3)
      if(nargin==1)
        q3 = q0(4, :);
        q2 = q0(3, :);
        q1 = q0(2, :);
        q0 = q0(1, :);
      end
      [q0, q1, q2, q3] = math.Rotation.quatNorm(q0, q1, q2, q3);
      q00 = q0.*q0;
      q11 = q1.*q1;
      q22 = q2.*q2;
      q33 = q3.*q3;
      q01 = q0.*q1;
      q12 = q1.*q2;
      q23 = q2.*q3;
      q03 = q0.*q3;
      q02 = q0.*q2;
      q13 = q1.*q3;
      r00 = q00+q11-q22-q33;
      r10 = 2.0*(q12+q03);
      r20 = 2.0*(q13-q02);
      r01 = 2.0*(q12-q03);
      r11 = q00-q11+q22-q33;
      r21 = 2.0*(q23+q01);
      r02 = 2.0*(q13+q02);
      r12 = 2.0*(q23-q01);
      r22 = q00-q11-q22+q33;
      if(nargout<=1)
        r00 = shiftdim(reshape(cat(1, r00(:), r10(:), r20(:), r01(:), r11(:), r21(:), r02(:), r12(:), r22(:)), ...
          numel(r00), 3, 3), 1);
      end
    end

    function h = quatToHomo(q0, q1, q2, q3)
      if(nargin==1)
        q3 = q0(4, :);
        q2 = q0(3, :);
        q1 = q0(2, :);
        q0 = q0(1, :);
      end
      h = zeros(4, 4, numel(q0));
      if(~isnumeric(q0))
        h = sym(h);
      end
      h(1, 1, :) = q0;
      h(2, 1, :) = q1;
      h(3, 1, :) = q2;
      h(4, 1, :) = q3;      
      h(1, 2, :) = -q1;
      h(2, 2, :) = q0;
      h(3, 2, :) = q3;
      h(4, 2, :) = -q2;
      h(1, 3, :) = -q2;
      h(2, 3, :) = -q3;
      h(3, 3, :) = q0;
      h(4, 3, :) = q1;
      h(1, 4, :) = -q3;
      h(2, 4, :) = q2;
      h(3, 4, :) = -q1;
      h(4, 4, :) = q0;
    end
    
    function [q0, q1, q2, q3] = homoToQuat(h)
      q0 = h(1, 1, :);
      q1 = h(2, 1, :);
      q2 = h(3, 1, :);
      q3 = h(4, 1, :);
      if(nargout<=1)
        q0 = shiftdim(reshape(cat(1, q0(:), q1(:), q2(:), q3(:)), numel(q0), 4), 1);
      end
    end
    
    function [qNorm0, qNorm1, qNorm2, qNorm3] = quatNorm(q0, q1, q2, q3)
      if(nargin==1)
        q3 = q0(4, :);
        q2 = q0(3, :);
        q1 = q0(2, :);
        q0 = q0(1, :);
      end
      qNorm0 = q0;
      qNorm1 = q1;
      qNorm2 = q2;
      qNorm3 = q3;
      if(isnumeric(q0))
        n = sqrt(q0.*q0+q1.*q1+q2.*q2+q3.*q3);
        small = find(n<eps);
        qNorm0(small) = 1.0;
        qNorm1(small) = 0.0;
        qNorm2(small) = 0.0;
        qNorm3(small) = 0.0;
        n(small) = 1.0;
        neg = find(qNorm0<0.0);
        n(neg) = -n(neg);
        qNorm0 = qNorm0./n;
        qNorm1 = qNorm1./n;
        qNorm2 = qNorm2./n;
        qNorm3 = qNorm3./n;
      end
      if(nargout<=1)
        qNorm0 = shiftdim(reshape(cat(1, qNorm0(:), qNorm1(:), qNorm2(:), qNorm3(:)), numel(qNorm0), 4), 1);
      end
    end
    
    function [qInv0, qInv1, qInv2, qInv3] = quatInv(q0, q1, q2, q3)
      if(nargin==1)
        q3 = q0(4, :);
        q2 = q0(3, :);
        q1 = q0(2, :);
        q0 = q0(1, :);
      end
      qInv0 = q0;
      qInv1 = -q1;
      qInv2 = -q2;
      qInv3 = -q3;
      if(nargout<=1)
        qInv0 = shiftdim(reshape(cat(1, qInv0(:), qInv1(:), qInv2(:), qInv3(:)), numel(qInv0), 4), 1);
      end
    end
    
    function [c0, c1, c2, c3] = quatMult(a0, a1, a2, a3, b0, b1, b2, b3)
      if(nargin==2)
        b3 = a1(4, :);
        b2 = a1(3, :);
        b1 = a1(2, :);
        b0 = a1(1, :);
        a3 = a0(4, :);
        a2 = a0(3, :);
        a1 = a0(2, :);
        a0 = a0(1, :);
      end
      c0 = a0.*b0-a1.*b1-a2.*b2-a3.*b3;
      c1 = a1.*b0+a0.*b1-a3.*b2+a2.*b3;
      c2 = a2.*b0+a3.*b1+a0.*b2-a1.*b3;
      c3 = a3.*b0-a2.*b1+a1.*b2+a0.*b3;
      if(nargout<=1)
        c0 = shiftdim(reshape(cat(1, c0(:), c1(:), c2(:), c3(:)), numel(c0), 4), 1);
      end
    end

    function c = mtimes(a, b)
      c = a*b;
    end
    
    function c = cross(a, b)
      c = cross(a, b);
    end

    function a = wrapToPI(a)
      twopi = 2.0*pi;
      a = mod(a, twopi);
      a = mod(a+twopi, twopi);
      b = a>pi;
      a(b) = a(b)-twopi;
    end
  end
end
