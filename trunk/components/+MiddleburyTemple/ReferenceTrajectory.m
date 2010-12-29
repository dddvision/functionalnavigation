classdef ReferenceTrajectory < tom.Trajectory

  properties (Constant = true, GetAccess = private)
    splineTension = 0;
  end
  
  properties (Access = private)
    tRef
    pRef
    qRef
    rRef
    sRef
    dqRef
    wRef
  end
  
  methods (Access = public)
    function this = ReferenceTrajectory(t, p, q, r, s)

      % get number of elements
      K = numel(t);
      
      % ensure that quaternions are unit magnitude to machine precision
      q = QuatNorm(q);

      % preprocessing incremental rotations and ensuring positive first element
      dq = zeros(4, K-1);
      for j = 1:(K-1)
        dq(:, j) = Quat2Homo(QuatConj(q(:, j)))*q(:, j+1); 
        dq(:, j) = dq(:, j)*sign(dq(1, j));
      end
      
      % convert rotation rates to axis-angle form
      w = zeros(3, K);
      for i = 1:K
        w(:, i) = s(:,i); % 2*invJexp(q(:, i))*s(:, i);
      end
      
      this.tRef = t;
      this.pRef = p;
      this.qRef = q;
      this.rRef = r;
      this.sRef = s;
      this.dqRef = dq;
      this.wRef = w;
    end
    
    function interval = domain(this)
      interval = tom.TimeInterval(tom.WorldTime(this.tRef(1)), tom.WorldTime(this.tRef(end)));
    end
    
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        t = double(t);
        pose(1, N) = tom.Pose;
        interval = domain(this);
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        good = lowerBound&upperBound;
        p = cardinalSpline(this.tRef, this.pRef, t(good), this.splineTension);
        q = QuatInterp(this.tRef, this.qRef, this.dqRef, this.wRef, t(good));
        k = 1;
        for n = find(lowerBound)
          if(upperBound(n))
            pose(n).p = p(:, k);
            pose(n).q = q(:, k);
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
      if(N==0);
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        t = double(t);
        tangentPose(1, N) = tom.TangentPose;
        interval = domain(this);
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        good = lowerBound&upperBound;
        [p, r] = cardinalSpline(this.tRef, this.pRef, t(good), this.splineTension);
        [q, qdot] = QuatInterp(this.tRef, this.qRef, this.dqRef, this.wRef, t(good));
        k = 1;
        for n = find(lowerBound)
          if(upperBound(n))
            tangentPose(n).p = p(:, k);
            tangentPose(n).q = q(:, k);
            tangentPose(n).r = r(:, k);
            w = Quat2Homo(QuatConj(q(:, k)))*(2*qdot(:, k)); % 2*conj(q)*qdot
            tangentPose(n).s = w(2:4);
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

function pose = predictPose(tP, dt)
  N = numel(dt);
  if(N==0)
    pose = repmat(tom.Pose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  dq = AxisAngle2Quat(tP.s*dt);
  q = Quat2HomoReverse(tP.q)*dq; % dq*q
  
  pose(1, N) = tom.Pose;
  for n = 1:N
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
  dq = AxisAngle2Quat(tP.s*dt); 
  q = Quat2HomoReverse(tP.q)*dq; % dq*q

  tangentPose(1, N) = tP;
  for n = 1:N
    tangentPose(n).p = p(:, n);
    tangentPose(n).q = q(:, n);
    tangentPose(n).r = tP.r;
    tangentPose(n).s = tP.s;
  end
end

% Performs quaternion interpolation using a Hermite spline
%
% NOTES
% Assumes tRef is always increasing
% Assumes t is within the range of tRef
function [qi, qidot] = QuatInterp(tRef, qRef, dqRef, wRef, t)
  N = numel(t);
  qi = zeros(4, N);
  if(nargout>1)
    qidot = zeros(4, N);
  end
  if(N==0)
    return;
  end
  j = 1;
  for i = 1:N % for each interpolation point
    while(tRef(j+1)<t(i))
      j = j+1;
    end
    dt = (t(i)-tRef(j))/(tRef(j+1)-tRef(j));
    qa = qRef(:, j);
    w1 = wRef(:, j)/3;
    w3 = wRef(:, j+1)/3;
    w2 = Quat2AxisAngle(Quat2Homo(QuatConj(AxisAngle2Quat(w1)))*Quat2Homo(dqRef(:, j))*QuatConj(AxisAngle2Quat(w3)));
    B = Bh(dt);
    Bd = Bhd(dt);
    qo = Quat2Homo(qa);
    exp1 = Quat2Homo(AxisAngle2Quat(B(1)*w1));
    exp2 = Quat2Homo(AxisAngle2Quat(B(2)*w2));
    exp3 = Quat2Homo(AxisAngle2Quat(B(3)*w3));
    wbd1 = Quat2Homo([0;Bd(1)*w1]);
    wbd2 = Quat2Homo([0;Bd(2)*w2]);
    wbd3 = Quat2Homo([0;Bd(3)*w3]);
    qi(:, i) = qo*exp1*exp2*Homo2Quat(exp3);
    if(nargout>1)
      qidot(:, i) = qo*exp1*wbd1*exp2*Homo2Quat(exp3)+qo*exp1*exp2*wbd2*Homo2Quat(exp3)+...
        qo*exp1*exp2*exp3*Homo2Quat(wbd3);
    end
  end
  if(nargout>1)
    [qi, qidot] = QuatNorm(qi, qidot);
  else
    qi = QuatNorm(qi);
  end
end

function x = Bh(t)
  tc = t.^3;
  x(1, :) = 1-(1-t).^3;
  x(2, :) = 3*t.*t-2*tc;
  x(3, :) = tc;
end

function xd = Bhd(t)
  xd(1, :) = 3*(1-t).^2;
  xd(2, :) = 6*t.*(1-t);
  xd(3, :) = 3*t.*t;
end

% Cardinal spline interpolation
%
% INPUT
% @param[in]  tRef reference times, double 1-by-N
% @param[in]  pRef reference values, double D-by-N
% @param[in]  t    interpolation times, double 1-by-K
% @param[in]  c    (default 0) tension parameter, double scalar
% @param[out] p    values at interpolation times, double D-by-K
% @param[out] r    derivatives with respect to time at interpolation times, double D-by-K
%
% NOTES
% Returns initial values if queried before tRef(1)
% Returns final values if queried after tRef(N) 
% The default tension parameter yields a Catman Hull spline
function [p, r] = cardinalSpline(tRef, pRef, t, c)

  [D,N] = size(pRef);
  K = numel(t);
  p = zeros(D, K);
  r = zeros(D, K);
  
  if(K==0)
    return;
  end
   
  if(N<2)
    error('At least two points are required to interpolate');
  end

  % transpose reference points for convienience
  pRef = pRef';
  
  % compute the slopes at each given point
  if(nargin<4)
    c = 0;
  end
  wt = (1-c);
  m = zeros(size(pRef));
  m(1, :) = wt*(pRef(2, :)-pRef(1, :))./(tRef(2)-tRef(1));
  for n = 2:(N-1)
    m(n, :) = wt*(pRef(n+1, :)-pRef(n-1, :))./(tRef(n+1)-tRef(n-1));
  end
  m(end, :) = wt*(pRef(end, :)-pRef(end-1, :))/(tRef(end)-tRef(end-1));
 
  % interpolate
  for k = 1:K
    tIndex = find(t(k)>=tRef,1,'last');

    if(isempty(tIndex))
      tIndex = 1;
    end

    if(tIndex==N)
      tIndex = N-1;
    end
    
    tPlus = tIndex+1;
    tRange = tRef(tPlus)-tRef(tIndex);
    tNorm = (t(k)-tRef(tIndex))./tRange;

    h00 = 2*tNorm.^3-3*tNorm.^2+1;
    h10 = tNorm.^3-2*tNorm.^2+tNorm;
    h01 = -2*tNorm.^3+3*tNorm.^2;
    h11 = tNorm.^3-tNorm.^2;

    h00dot = 6*tNorm.^2-6*tNorm;
    h10dot = 3*tNorm.^2-4*tNorm+1;
    h01dot = -6*tNorm.^2+6*tNorm;
    h11dot = 3*tNorm.^2-2*tNorm;

    p(:, k) = (h00.*pRef(tIndex, :)+h10.*(tRange).*m(tIndex, :)+h01.*pRef(tPlus, :)+h11.*(tRange).*m(tPlus, :))';
    r(:, k) = ((h00dot.*pRef(tIndex, :)+h10dot.*(tRange).*m(tIndex, :)+h01dot.*pRef(tPlus, :)+...
      h11dot.*(tRange).*m(tPlus, :))')/(tRange);
  end
end

function v = Quat2AxisAngle(q)
  q1 = q(1, :);
  q2 = q(2, :);
  q3 = q(3, :);
  q4 = q(4, :);

  theta = 2*real(acos(q1));
  
  n = sqrt(q2.*q2+q3.*q3+q4.*q4);
  n(n<eps) = eps;
  
  a = q2./n;
  b = q3./n;
  c = q4./n;

  v1 = theta.*a;
  v2 = theta.*b;
  v3 = theta.*c;

  v = [v1; v2; v3];
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

function q = Homo2Quat(h)
  q = [h(1); h(2); h(3); h(4)];
end

function q = QuatConj(q)
 q(2:4, :) = -q(2:4, :);
end

function [Q, Qdot] = QuatNorm(Q, Qdot)
  q1 = Q(1, :);
  q2 = Q(2, :);
  q3 = Q(3, :);
  q4 = Q(4, :);

  n = sqrt(q1.*q1+q2.*q2+q3.*q3+q4.*q4);

  s = sign(q1);
  s(s==0) = 1;
  ns = n.*s;
  
  Q(1, :) = q1./ns;
  Q(2, :) = q2./ns;
  Q(3, :) = q3./ns;
  Q(4, :) = q4./ns;
  
  if(nargout>1)
    Qdot(1, :) = s.*Qdot(1, :);
    Qdot(2, :) = s.*Qdot(2, :);
    Qdot(3, :) = s.*Qdot(3, :);
    Qdot(4, :) = s.*Qdot(4, :);
  end
end
