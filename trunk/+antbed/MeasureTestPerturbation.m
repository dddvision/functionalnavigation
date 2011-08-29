% Trajectory that can be perturbed over a time interval
classdef MeasureTestPerturbation < tom.Trajectory

  properties (GetAccess = private, SetAccess = private)
    offsetPose
    refTrajectory
    tempinterval
  end
    
  methods (Access = public, Static = true)
    function this = MeasureTestPerturbation(refTrajectory)
      this.refTrajectory = refTrajectory;
    end
  end
    
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = this.tempInterval;
    end
    
    function setPerturbation(this, offsetPose, tempInterval)
      refInterval = this.refTrajectory.domain();
      assert(tempInterval.first>=refInterval.first);
      assert(tempInterval.second<=refInterval.second);
      this.offsetPose = offsetPose;
      this.tempInterval = tempInterval;
    end
    
    function pose = evaluate(this, t)
      interval = this.refTrajectory.domain();
      initialTime = interval.first;
            
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        deltaTime = t-initialTime;                       
        pose(1, N) = tom.Pose;
        %TODO: Add interpolation for non-diecrete time values
        for k = 1:size(t)
          translation = deltaTime(k)*this.offsetPose.p;
          axisAngle = Quat2AxisAngle(this.offsetPose.q)*deltaTime(k);
          basePose = this.refTrajectory.evaluate(t(k));
          pose(k).p = basePose.p+translation;
          pose(k).q = Quat2Homo(AxisAngle2Quat(axisAngle))*basePose.q;
        end
      end   
    end
  
    % the method returns 0 for the change in rate of rotation, this may be
    % implemented in the future
    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose(1, N) = tom.TangentPose;
        for k = find(t>=this.initialTime)
          tangentPose(k).p = this.basePose.p + this.deltaPose.p;
          tangentPose(k).q = Quat2Homo(this.deltaPose.q) * this.basePose.q;
          tangentPose(k).r = [0; 0; 0];
          tangentPose(k).s = [0; 0; 0];
        end
      end
    end
  end
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

% Interpolates x(t) on the interval [tA, tB]
% 
% @param[in]  pB       value of x(tB)
% @param[in]  rB       value of (dx/dt)(tB)
% @param[in]  interval time domain, tom.TimeInterval
% @param[in]  t        value of t on the interval [tA, tB], tom.WorldTime
% @param[out] pt       value of x(t)
% @param[out] rt       value of (dx/dt)(t)
%
% NOTES
% The values of x(tA) and (dx/dt)(tA) are assumed to be 0
function [pt, rt] = perturbation(interval, pB, rB, t)
  K = numel(t);

  % process (t<=tA)
  pt = zeros(1, K);
  rt = zeros(1, K);
  tA = double(interval.first);
  tB = double(interval.second);
  t = double(t);
  
  % set origin at tA
  t = t-tA;
  tB = tB-tA;
  tA = 0;

  % process (t>tA)&(t<=tB))
  k = find((t>tA)&(t<=tB));
  tB2 = tB*tB;
  tB3 = tB*tB2;
  t2 = t(k).*t(k);
  t3 = t(k).*t2;
  c = 3/tB2*pB-rB/tB;
  d = rB/tB2-2/tB3*pB;
  pt(k) = c*t2+d*t3;
  rt(k) = (2*c*t(k)+3*d*t2);
  
  % set origin at tB
  t = t-tB;
  tB = 9;
  
  % process t>tB
  k = find(t>tB);
  pt(k) = pB+rB*t(k);
  rt(k) = rB*ones(1, numel(k));
end
