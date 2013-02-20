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
      q = tom.Rotation.quatNorm(q);

      % preprocessing incremental rotations and ensuring positive first element
      dq = zeros(4, K-1);
      for j = 1:(K-1)
        dq(:, j) = tom.Rotation.quatMult(q(:, j+1), q(:, j)); 
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
      interval = hidi.TimeInterval(this.tRef(1), this.tRef(end));
    end
    
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        t = double(t);
        pose(1, N) = tom.Pose;
        interval = this.domain();
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
            finalTangentPose = this.tangent(interval.second);
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
        interval = this.domain();
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
            w = tom.Rotation.quatMult(2*qdot(:, k), q(:, k)); % 2*conj(q)*qdot
            tangentPose(n).s = w(2:4);
            k = k+1;
          else
            finalTangentPose = this.tangent(interval.second);
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
  dq = tom.Rotation.axisToQuat(tP.s*dt);
  q = tom.Rotation.quatMult(dq, tP.q);
  
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
  dq = tom.Rotation.axisToQuat(tP.s*dt); 
  q = tom.Rotation.quatMult(dq, tP.q);

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
    w2 = tom.Rotation.quatToAxis(tom.Rotation.quatToHomo(tom.Rotation.quatInv(tom.Rotation.axisToQuat(w1)))*...
      tom.Rotation.quatToHomo(dqRef(:, j))*tom.Rotation.quatInv(tom.Rotation.axisToQuat(w3)));
    B = Bh(dt);
    Bd = Bhd(dt);
    qo = tom.Rotation.quatToHomo(qa);
    exp1 = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(B(1)*w1));
    exp2 = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(B(2)*w2));
    exp3 = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(B(3)*w3));
    wbd1 = tom.Rotation.quatToHomo([0;Bd(1)*w1]);
    wbd2 = tom.Rotation.quatToHomo([0;Bd(2)*w2]);
    wbd3 = tom.Rotation.quatToHomo([0;Bd(3)*w3]);
    qi(:, i) = qo*exp1*exp2*tom.Rotation.homoToQuat(exp3);
    if(nargout>1)
      qidot(:, i) = qo*exp1*wbd1*exp2*tom.Rotation.homoToQuat(exp3)+qo*exp1*exp2*wbd2*tom.Rotation.homoToQuat(exp3)+...
        qo*exp1*exp2*exp3*tom.Rotation.homoToQuat(wbd3);
    end
  end
  if(nargout>1)
    s = sign(qi(1, :));
    qidot(1, :) = s.*qidot(1, :);
    qidot(2, :) = s.*qidot(2, :);
    qidot(3, :) = s.*qidot(3, :);
    qidot(4, :) = s.*qidot(4, :);    
  end
  qi = tom.Rotation.quatNorm(qi);
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
