% Trajectory that can be perturbed over a time interval
classdef MeasureTestPerturbation < tom.Trajectory

  properties (GetAccess = private, SetAccess = private)
    tangentPoseOffsetB
    refTrajectory
    interval
  end
    
  methods (Access = public, Static = true)
    function this = MeasureTestPerturbation(refTrajectory)
      this.refTrajectory = refTrajectory;
    end
  end
    
  methods (Access = public)
    function interval = domain(this)
      interval = this.interval;
    end
    
    function setPerturbation(this, interval, tangentPoseOffsetB)
      refInterval = this.refTrajectory.domain();
      assert(interval.first>=refInterval.first);
      assert(interval.second<=refInterval.second);
      this.tangentPoseOffsetB = tangentPoseOffsetB;
      this.interval = interval;
    end
    
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        pPerturb = zeros(3, N);
        aPerturb = zeros(3, N);
        tA = double(this.interval.first);
        tB = double(this.interval.second);
        pB = this.tangentPoseOffsetB.p;
        aB = tom.Rotation.quatToAxis(this.tangentPoseOffsetB.q);
        rB = this.tangentPoseOffsetB.r;
        sB = this.tangentPoseOffsetB.s;
        for dim = 1:3
          pPerturb(dim, :) = MTPerturb(tA, tB, pB(dim), rB(dim), t);
          aPerturb(dim, :) = MTPerturb(tA, tB, aB(dim), sB(dim), t); % small angle approximation
        end
        % mix perturbation with reference trajectory
        pose = this.refTrajectory.evaluate(t);
        for n = 1:N
          pose(n).p = pose(n).p+pPerturb(:, n);
          pose(n).q = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(aPerturb(:, n)))*pose(n).q;  % small angle approximation
        end
      end   
    end
  
    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        pPerturb = zeros(3, N);
        aPerturb = zeros(3, N);
        rPerturb = zeros(3, N);
        sPerturb = zeros(3, N);
        tA = double(this.interval.first);
        tB = double(this.interval.second);

        pB = this.tangentPoseOffsetB.p;
        aB = tom.Rotation.quatToAxis(this.tangentPoseOffsetB.q);
        rB = this.tangentPoseOffsetB.r;
        sB = this.tangentPoseOffsetB.s;
        for dim = 1:3
          [pPerturb(dim, :), rPerturb(dim, :)] = MTPerturb(tA, tB, pB(dim), rB(dim), t);
          [aPerturb(dim, :), sPerturb(dim, :)] = MTPerturb(tA, tB, aB(dim), sB(dim), t); % small angle approximation
        end
        % mix perturbation with reference trajectory
        tangentPose = this.refTrajectory.tangent(t);
        for n = 1:N
          tangentPose(n).p = tangentPose(n).p+pPerturb(:, n);
          tangentPose(n).q = tom.Rotation.quatToHomo(tom.Rotation.axisToQuat(aPerturb(:, n)))*tangentPose(n).q; % small angle approximation
          tangentPose(n).r = tangentPose(n).r+rPerturb(:, n);
          tangentPose(n).s = tangentPose(n).s+sPerturb(:, n); % small angle approximation
        end
      end
    end
  end
end

% Evaluates the one-dimensional 3rd-order perturbation function x(t) on the interval [tA, Inf].
% 
% @param[in]  tA time at node A, double scalar
% @param[in]  tB time at node B, double scalar
% @param[in]  pB value of x(tB), double scalar
% @param[in]  rB value of (dx/dt)(tB), double scalar
% @param[in]  t  value of t on the interval [tA, Inf], double 1-by-K
% @param[out] pt value of x(t), double 1-by-K
% @param[out] rt value of (dx/dt)(t), double 1-by-k
%
% NOTES
% In the case of tA==tB the function discontinuously jumps to the perturbed value at tA.
% The values of x(tA) and (dx/dt)(tA) are assumed to be 0.
% The output represents steady motion after tB.
function [pt, rt] = MTPerturb(tA, tB, pB, rB, t)
  assert(size(t, 1)==1);
  K = numel(t);

  % initialize and process (t<=tA)
  pt = zeros(1, K);
  if(nargout>1)
    rt = zeros(1, K);
  end
  
  % special exception for (tA==tB)
  if(tA==tB)
    k = (t==tA);
    pt(k) = pB;
    if(nargout>1)
      rt(k) = rB;
    end
  end
  
  % set origin at tA
  t = t-tA;
  tB = tB-tA;
  tA = 0;

  % process (t>tA)&(t<=tB))
  k = (t>tA)&(t<=tB);
  tB2 = tB*tB;
  tB3 = tB*tB2;
  t2 = t(k).*t(k);
  t3 = t(k).*t2;
  c = 3/tB2*pB-rB/tB;
  d = rB/tB2-2/tB3*pB;
  pt(k) = c*t2+d*t3;
  if(nargout>1)
    rt(k) = (2*c*t(k)+3*d*t2);
  end
    
  % set origin at tB
  t = t-tB;
  tB = 0;
  
  % process (t>tB)
  k = (t>tB);
  pt(k) = pB+rB*t(k);
  if(nargout>1)
    rt(k) = repmat(rB, [1, sum(k)]);
  end
end
