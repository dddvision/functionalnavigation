% y = body orientation in Euler angle form (3-by-K)
% v = body orientation in axis angle form (3-by-K)
% q = body orientation in quaternion form <scalar,vector> form (4-by-K)
% R = matrices that rotate a point from the body frame to the world frame (3-by-3-by-K)
classdef Rotation 
  methods (Access = public, Static = true)
    function y = axisToEuler(v)
      R = tom.Rotation.axisToMatrix(v);
      y = tom.Rotation.matrixToEuler(R);
    end
    
    % @note
    % Implements Rodrigues' Formula (a form of exponential mapping)
    function R = axisToMatrix(v)
      K = size(v, 2);
      R = zeros(3, 3, K);
      for k = 1:K
        er = v(:, k);
        theta = sqrt(er'*er);
        if(isnumeric(theta))
          if(abs(theta)<eps)
            R(:, :, k) = eye(3);
            continue;
          end
        else
          if(theta==0)
            R(:, :, k) = eye(3);
            continue;
          end
        end
        u = er/theta;
        uhat = [[    0,-u(3), u(2)]
                [ u(3),    0,-u(1)]
                [-u(2), u(1),    0]];
        R(:, :, k) = eye(3)+uhat*sin(theta)+uhat*uhat*(1.0-cos(theta));
      end
    end

    function q = axisToQuat(v)
      v1 = v(1, :);
      v2 = v(2, :);
      v3 = v(3, :);
      n = sqrt(v1.*v1+v2.*v2+v3.*v3);
      N = numel(n);
      if(isnumeric(v))
        good = n>eps;
      else
        good = true(1, N);
      end
      ngood = n(good);
      a = zeros(1, N);
      b = zeros(1, N);
      c = zeros(1, N);
      th2 = zeros(1, N);
      a(good) = v1(good)./ngood;
      b(good) = v2(good)./ngood;
      c(good) = v3(good)./ngood;
      th2(good) = ngood/2.0;
      s = sin(th2);
      q1 = cos(th2);
      q2 = s.*a;
      q3 = s.*b;
      q4 = s.*c;
      q = [q1; q2; q3; q4];
      q = tom.Rotation.quatNorm(q);
    end
    
    function v = eulerToAxis(y)
      q = tom.Rotation.eulerToQuat(y);
      v = tom.Rotation.quatToAxis(q);
    end
    
    function R = eulerToMatrix(y)
      K = size(y, 2);
      R = zeros(3, 3, K);
      if(~isnumeric(y))
        R = sym(R);
      end
      y0 = y(1, :);
      y1 = y(2, :);
      y2 = y(3, :);
      c0 = cos(y0);
      c1 = cos(y1);
      c2 = cos(y2);
      s1 = sin(y0);
      s2 = sin(y1);
      s3 = sin(y2);
      R(1, 1, :) = c2.*c1;
      R(1, 2, :) = c2.*s2.*s1-s3.*c0;
      R(1, 3, :) = s3.*s1+c2.*s2.*c0;
      R(2, 1, :) = s3.*c1;
      R(2, 2, :) = c2.*c0+s3.*s2.*s1;
      R(2, 3, :) = s3.*s2.*c0-c2.*s1;
      R(3, 1, :) = -s2;
      R(3, 2, :) = c1.*s1;
      R(3, 3, :) = c1.*c0;
    end
    
    function q = eulerToQuat(y)
      K = size(y, 2);
      q = zeros(4, K);
      if(~isnumeric(y))
        q = sym(q);
      end
      y0 = y(1, :);
      y1 = y(2, :);
      y2 = y(3, :);
      c0 = cos(y0/2.0);
      c1 = cos(y1/2.0);
      c2 = cos(y2/2.0);
      s1 = sin(y0/2.0);
      s2 = sin(y1/2.0);
      s3 = sin(y2/2.0);
      q(1, :) = c2.*c1.*c0+s3.*s2.*s1;
      q(2, :) = c2.*c1.*s1-s3.*s2.*c0;
      q(3, :) = c2.*s2.*c0+s3.*c1.*s1;
      q(4, :) = s3.*c1.*c0-c2.*s2.*s1;
      q = tom.Rotation.quatNorm(q);
    end

    % Convert rotation matrices to axis-angle form
    %
    % INPUT
    % R = rotation matrices in layers, 3-by-3-by-K
    %
    % OUTPUT
    % v = rotation vectors in axis-angle form, 3-by-K
    %
    % NOTES
    % The magnitude of the output vector is the rotation angle in radians
    % By Tony Falcone and David Diel
    function v = matrixToAxis(R)
      K = size(R, 3);
      v = zeros(3, K);
      for k = 1:K
        r00 = R(1, 1, k);
        r10 = R(2, 1, k);
        r20 = R(3, 1, k);
        r01 = R(1, 2, k);
        r11 = R(2, 2, k);
        r21 = R(3, 2, k);
        r02 = R(1, 3, k);
        r12 = R(2, 3, k);
        r22 = R(3, 3, k);
        a00 = r00-1.0;
        if(a00<0.0)
          a11 = r11-(r10/a00)*r01;
          a12 = r12-(r10/a00)*r02;
          a21 = r21-(r20/a00)*r01;
          a22 = r22-(r20/a00)*r02;
          if((abs(a11-1.0)+abs(a12))>(abs(a21)+abs(a22-1.0)))
            v2 = 1.0;
            v1 = -a12/(a11-1.0);
          else
            v1 = 1.0;
            v2 = -a21/(a22-1.0);
          end
          v0 = -(r01*v1+r02*v2)/a00;
          n = sqrt(v0*v0+v1*v1+v2*v2);
          v0 = v0/n;
          v1 = v1/n;
          v2 = v2/n;
        else
          v0 = 1.0;
          v1 = 0.0;
          v2 = 0.0;
        end
        b = acos((r00+r11+r22-1.0)/2.0);
        v(1, k) = v0*b;
        v(2, k) = v1*b;
        v(3, k) = v2*b;
      end
    end
    
    function y = matrixToEuler(R)
      N = size(R, 3);
      y = zeros(3, N);
      if(isnumeric(R))
        y(1, :) = atan2(R(3, 2, :), R(3, 3, :));
        y(2, :) = asin(-R(3, 1, :));
        y(3, :) = atan2(R(2, 1, :), R(1, 1, :));
      else
        R = sym(R); 
        y = sym(y);
        y(1, :) = atan(R(3, 2, :)./R(3, 3, :));
        y(2, :) = asin(-R(3, 1, :));
        y(3, :) = atan(R(2, 1, :)./R(1, 1, :));
      end
    end
    
    function q = matrixToQuat(R)
      y = tom.Rotation.matrixToEuler(R);
      q = tom.Rotation.eulerToQuat(y);
    end

    function v = quatToAxis(q)
      q = tom.Rotation.quatNorm(q);
      s = q(1, :);
      a = q(2, :);
      b = q(3, :);
      c = q(4, :);
      n = sqrt(a.*a+b.*b+c.*c);
      if(isnumeric(q))
        nonzero = find(n>eps);
        a(nonzero) = a(nonzero)./n(nonzero);
        b(nonzero) = b(nonzero)./n(nonzero);
        c(nonzero) = c(nonzero)./n(nonzero);
      else
        a = a./n;
        b = b./n;
        c = c./n;
      end
      theta = 2.0*acos(s);
      v0 = theta.*a;
      v1 = theta.*b;
      v2 = theta.*c;
      v = [v0; v1; v2];
    end
    
    function y = quatToEuler(q)
      y = zeros(3, size(q, 2));
      if(~isnumeric(q))
        y = sym(y);
      end
      q = tom.Rotation.quatNorm(q);
      q0 = q(1, :);
      q1 = q(2, :);
      q2 = q(3, :);
      q3 = q(4, :);
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
      if(isnumeric(q))
        y(1, :) = atan2(2.0*(q23+q01), q00-q11-q22+q33);
        y(2, :) = asin(min(max(-2.0*(q13-q02), -1.0), 1.0));
        y(3, :) = atan2(2.0*(q12+q03), q00+q11-q22-q33);
      else
        y(1, :) = atan((2.0*(q23+q01))./(q00-q11-q22+q33));
        y(2, :) = asin(-2.0*(q13-q02));
        y(3, :) = atan((2.0*(q12+q03))./(q00+q11-q22-q33));
      end
    end
    
    % Converts a set of quaternions to a set of rotation matrices.
    function R = quatToMatrix(q)
      R = zeros(3, 3, size(q, 2));
      if(~isnumeric(q))
        R = sym(R);
      end
      q = tom.Rotation.quatNorm(q);
      q0 = q(1, :);
      q1 = q(2, :);
      q2 = q(3, :);
      q3 = q(4, :);
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
      R(1, 1, :) = q00+q11-q22-q33;
      R(2, 1, :) = 2.0*(q12+q03);
      R(3, 1, :) = 2.0*(q13-q02);
      R(1, 2, :) = 2.0*(q12-q03);
      R(2, 2, :) = q00-q11+q22-q33;
      R(3, 2, :) = 2.0*(q23+q01);
      R(1, 3, :) = 2.0*(q13+q02);
      R(2, 3, :) = 2.0*(q23-q01);
      R(3, 3, :) = q00-q11-q22+q33;
    end
    
    % Converts a quaternion into homogenous form
    %
    % @note
    % Premultiplication corresponds to rotation of an inner gimbaled axis
    % Usage: qac = quatToHomo(qab)*qbc;
    function H = quatToHomo(q)
      H = zeros(4, 4, size(q, 2));
      if(~isnumeric(q))
        H = sym(H);
      end
      q0 = q(1, :);
      q1 = q(2, :);
      q2 = q(3, :);
      q3 = q(4, :);
      H(1, 1, :) = q0;
      H(2, 1, :) = q1;
      H(3, 1, :) = q2;
      H(4, 1, :) = q3;      
      H(1, 2, :) = -q1;
      H(2, 2, :) = q0;
      H(3, 2, :) = q3;
      H(4, 2, :) = -q2;
      H(1, 3, :) = -q2;
      H(2, 3, :) = -q3;
      H(3, 3, :) = q0;
      H(4, 3, :) = q1;
      H(1, 4, :) = -q3;
      H(2, 4, :) = q2;
      H(3, 4, :) = -q1;
      H(4, 4, :) = q0;
    end
    
    % Normalizes each quaternion to have unit magnitude and a non-negative first element
    function q = quatNorm(q)
      if(~isnumeric(q))
        return;
      end
      q0 = q(1, :);
      q1 = q(2, :);
      q2 = q(3, :);
      q3 = q(4, :);
      n = sqrt(q0.*q0+q1.*q1+q2.*q2+q3.*q3);
      bad = find(n<eps);
      q0(bad) = 1.0;
      q1(bad) = 0.0;
      q2(bad) = 0.0;
      q3(bad) = 0.0;
      neg = find(q0<0.0);
      n(neg) = -n(neg);
      q(1, :) = q0./n;
      q(2, :) = q1./n;
      q(3, :) = q2./n;
      q(4, :) = q3./n;
    end
    
    % Returns the conjugate (inverse) of the input quaternion
    function q = quatConj(q)
      q(2:4, :) = -q(2:4, :);
    end
  end
end
