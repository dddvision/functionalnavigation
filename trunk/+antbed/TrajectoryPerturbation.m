classdef TrajectoryPerturbation < tom.Trajectory

  properties (GetAccess = private, SetAccess = private)
      deltaPoseUnit
      baseTrajectory
  end
    
  methods (Access = public, Static = true)
    % base trajectory and rotation (ie ground truth) passed as a tom.pose
    function this = TrajectoryPerturbation(refTrajectory)
      this.baseTrajectory = refTrajectory;
    end
  end
    
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = domain(this.baseTrajectory);
    end
    function setPerturbation(this, offsetPose)
      this.deltaPoseUnit = offsetPose;
    end
    
    function pose = evaluate(this, t)
      interval = this.baseTrajectory.domain();
      initialTime = interval.first;
            
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        deltaTime = t-initialTime;                       
        pose(1, N) = tom.Pose;
        %TODO: Add interpolation for non-diecrete time values
        for k = 1:size(t)
          translation = deltaTime(k) * this.deltaPoseUnit.p;
          axisAngle = Quat2AxisAngle(this.deltaPoseUnit.q) * deltaTime(k);
          basePose = this.baseTrajectory.evaluate(t(k));
          pose(k).p = basePose.p + translation;
          pose(k).q = Quat2Homo(AxisAngle2Quat(axisAngle)) * basePose.q;
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

  scale = 2 * acos(q1);   
  q1Sq = q1 .* q1;
  demon = sqrt(1-q1Sq);
  v=zeros(3,size(q,2));
  for i=1:size(q,2)
    if(q1(i)==1)
      v(:,i) = [0;0;0];
    else    
      a(1) = q2(i) / demon(i);
      a(2) = q3(i) / demon(i);
      a(3) = q4(i) / demon(i);   
      aNorm = a / norm(a);

      vT = aNorm * scale(i);
      v(:,i) = vT';
    end   
  end
end
