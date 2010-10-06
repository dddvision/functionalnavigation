classdef BodyReference < tom.Trajectory
  
  properties (SetAccess = private, GetAccess = private)
    T_imu
    x_imu
  end  
  
  methods (Access = public)
    function this = BodyReference(initialTime, localCache, dataSetName)
      if(strcmp(dataSetName(1:6), 'Gantry'))
        S = load(fullfile(localCache, 'workspace.mat'), 'INITIAL_BODY_STATE');
        [this.T_imu, this.x_imu] = ReadGantry(fullfile(localCache, 'gantry_raw.dat'));
        N = size(this.x_imu, 2);
        this.x_imu = [repmat(S.INITIAL_BODY_STATE(1:4), [1, N]); this.x_imu];
      else
        S = load(fullfile(localCache, 'workspace.mat'), 'T_imu', 'x_imu');
        this.x_imu = S.x_imu;
        this.T_imu = S.T_imu;
        N = size(S.x_imu, 2);
      end
      
      % MIT laboratory location
      DTOR = pi/180;
      refLatitude = DTOR*42.3582722;
      refLongitude = DTOR*-71.0927417;
      
      % add initial time to recorded time (same policy for all sensors)
      this.T_imu = tom.WorldTime(this.T_imu+initialTime);
      
      % convert from tangent plane to ECEF
      Raxes = [[0, 0, -1]
               [0, 1,  0]
               [1, 0,  0]];
      refR = Euler2Matrix([0; -refLatitude; refLongitude])*Raxes;
      refT = lolah2ecef([refLongitude; refLatitude; 0]);
      refH = Quat2Homo(Euler2Quat(Matrix2Euler(refR)));
      this.x_imu(1:4, :) = refH*this.x_imu(1:4, :);
      this.x_imu(5:7, :) = refR*this.x_imu(5:7, :)+repmat(refT, [1, N]);
      
      % swap position and quaternion positions
      this.x_imu = this.x_imu([5, 6, 7, 1, 2, 3, 4], :);
    end

    function interval = domain(this)
      interval = tom.TimeInterval(tom.WorldTime(this.T_imu(1)), tom.WorldTime(this.T_imu(end)));
    end

    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, N]);
      else
        pose(1, N) = tom.Pose;
        interval = domain(this);
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        pq = cardinalSpline(this.T_imu, this.x_imu, t(lowerBound&upperBound));
        k = 1;
        for n = find(lowerBound)
          if(upperBound(n))
            pose(n).p = pq(1:3, k);
            pose(n).q = pq(4:7, k);
            k = k+1;
          else
            finalTangentPose = tangent(this, interval.second);
            pose(n) = predictPose(finalTangentPose, t(n)-interval.second);
          end
        end
      end
    end

    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose(1, N) = tom.TangentPose;
        interval = domain(this);
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        [pq, rs] = cardinalSpline(this.T_imu, this.x_imu, t(lowerBound&upperBound));
        k = 1;
        for n = find(lowerBound)
          if(upperBound(n))
            tangentPose(n).p = pq(1:3, k);
            tangentPose(n).q = pq(4:7, k);
            tangentPose(n).r = rs(1:3, k);
            tangentPose(n).s = rs(4:7, k);
            k = k+1;
          else
            finalTangentPose = tangent(this, interval.second);
            tangentPose(n) = predictTangentPose(finalTangentPose, t(n)-interval.second);
          end
        end
      end
    end
  end

end

function [t, x] = ReadGantry(filename)
  [tg, xg, yg, zg] = textread(filename, '%f %f %f %f');
  t = tg'-tg(1);
  s = sin(25*pi/180);
  c = cos(25*pi/180);
  N = yg*c-xg*s;
  E = -yg*s-xg*c;
  D = -zg;
  x = [N'; E'; D'];
end

% Cardinal Spline interpolation function
%
% INPUT
% t = time index of pts, double 1-by-N
% pts = points in M dimensions to be interpolated, double M-by-N
% test_t = times at which to interpolate, double 1-by-K
% c = (default 0) tension parameter, double scalar
%
% NOTES
% The default tension parameter yields a Catman Hull spline
function [pos, posdot] = cardinalSpline(t, pts, test_t, c)
  
  if(nargin<4)
    c = 0;
  end
  
  pts = pts';
  D = size(pts, 2);
  Ntest = numel(test_t);
  pos = zeros(D, Ntest);
  posdot = zeros(D, Ntest);
  
  if(Ntest==0)
    return;
  end
  
  Npts = size(pts, 1);
  
  if(Npts<2)
    error('At least two points are required to interpolate');
  end
  
  % compute the slopes at each given point
  wt = (1-c)./2;
  m = zeros(size(pts));
  for dim = 1:size(pts, 2)
    for indx = 2:(Npts-1)
      m(indx, :) = wt*(pts(indx+1, :)-pts(indx-1, :));
    end
  end
  m(1, :) = 2*wt*(pts(2, :)-pts(1, :));
  m(end, :) = 2*wt*(pts(end, :)-pts(end-1, :));
  
  % interpolate
  for indx = 1:Ntest
    t_indx = find(test_t(indx)>=t,1,'last');
  
    if(isempty(t_indx))
      t_indx = 1;
    end
    
    if(t_indx==Npts)
      t_indx = Npts-1;
    end
    
    t_range = t(t_indx+1)-t(t_indx);
    curr_t = (test_t(indx)-t(t_indx))./t_range;
    
    h00 = 2*curr_t.^3-3*curr_t.^2+1;
    h10 = curr_t.^3-2*curr_t.^2+curr_t;
    h01 = -2*curr_t.^3+3*curr_t.^2;
    h11 = curr_t.^3-curr_t.^2;
    
    h00dot = 6*curr_t.^2-6*curr_t;
    h10dot = 3*curr_t.^2-4*curr_t+1;
    h01dot = -6*curr_t.^2+6*curr_t;
    h11dot = 3*curr_t.^2-2*curr_t;
    
    pos(:, indx) = (h00.*pts(t_indx, :) + h10.*m(t_indx, :) + ...
      h01.*pts(t_indx+1, :) + h11.*m(t_indx+1, :))';
    posdot(:, indx) = (h00dot.*pts(t_indx, :) + h10dot.*m(t_indx, :) + ...
      h01dot.*pts(t_indx+1, :) + h11dot.*m(t_indx+1, :))';
  end
end

function Y = Matrix2Euler(R)
  Y = zeros(3, 1); 
  Y(1) = atan2(R(3, 2), R(3, 3));
  Y(2) = asin(-R(3, 1));
  Y(3) = atan2(R(2, 1), R(1, 1));
end

function Q = Euler2Quat(E)
  a = E(1, :);
  b = E(2, :);
  c = E(3, :);
  c1 = cos(a/2);
  c2 = cos(b/2);
  c3 = cos(c/2);
  s1 = sin(a/2);
  s2 = sin(b/2);
  s3 = sin(c/2);
  Q(1, :) = c3.*c2.*c1 + s3.*s2.*s1;
  Q(2, :) = c3.*c2.*s1 - s3.*s2.*c1;
  Q(3, :) = c3.*s2.*c1 + s3.*c2.*s1;
  Q(4, :) = s3.*c2.*c1 - c3.*s2.*s1;
end

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

function pose = predictPose(tP, dt)
  N = numel(dt);
  if(N==0)
    pose = repmat(tom.Pose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  w = Quat2Homo(QuatConj(tP.q))*(2*tP.s); % 2*conj(q)*qdot
  dq = AxisAngle2Quat(w(2:4)*dt);
  q = Quat2HomoReverse(tP.q)*dq; % dq*q
  
  pose(1, N) = tom.Pose;
  for n=1:N
    pose(n).p = p(:, n);
    pose(n).q = q(:, n);
  end
end

function tangentPose = predictTangentPose(tP, dt)
  N = numel(dt);
  if(N==0)
    tangentPose = repmat(tom.TangentPose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  w = Quat2Homo(QuatConj(tP.q))*(2*tP.s); % 2*conj(q)*qdot
  dq = AxisAngle2Quat(w(2:4)*dt); 
  q = Quat2HomoReverse(tP.q)*dq; % dq*q
  s = 0.5*Quat2HomoReverse(w)*q; % 0.5*q*w

  tangentPose(1, N) = tP;
  for n=1:N
    tangentPose(n).p = p(:, n);
    tangentPose(n).q = q(:, n);
    tangentPose(n).r = tP.r;
    tangentPose(n).s = s(:, n);
  end
end

function h = Quat2HomoReverse(q)
  q1 = q(1);
  q2 = q(2);
  q3 = q(3);
  q4 = q(4);
  h = [[q1, -q2, -q3, -q4]
       [q2,  q1,  q4, -q3]
       [q3, -q4,  q1,  q2]
       [q4,  q3, -q2,  q1]];
end

function h = Quat2Homo(q)
  q1 = q(1);
  q2 = q(2);
  q3 = q(3);
  q4 = q(4);
  h = [[q1, -q2, -q3, -q4]
       [q2,  q1, -q4,  q3]
       [q3,  q4,  q1, -q2]
       [q4, -q3,  q2,  q1]];
end

function q = QuatConj(q)
 q(2:4, :) = -q(2:4, :);
end

function q = AxisAngle2Quat(v)
  v1 = v(1, :);
  v2 = v(2, :);
  v3 = v(3, :);
  n = sqrt(v1.*v1+v2.*v2+v3.*v3);
  good = n>eps;
  ngood = n(good);
  N = numel(n);
  a = zeros(1, N);
  b = zeros(1, N);
  c = zeros(1, N);
  th2 = zeros(1, N);
  a(good) = v1(good)./ngood;
  b(good) = v2(good)./ngood;
  c(good) = v3(good)./ngood;
  th2(good) = ngood/2;
  s = sin(th2);
  q1 = cos(th2);
  q2 = s.*a;
  q3 = s.*b;
  q4 = s.*c;
  q = [q1; q2; q3; q4];
end
