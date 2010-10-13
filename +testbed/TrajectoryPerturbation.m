classdef TrajectoryPerturbation < Trajectory

  properties (GetAccess = private, SetAccess = private)
      translation
      rotation
      deltaTranslation
      deltaRotation
  end
    
  methods (Access = public, Static = true)
    % foward,right,down   -   quat
    % base trajectory and rotation (ie ground truth)
    function this = TrajectoryPerturbation(trans, rot)
      this.translation = trans;
      this.rotation = rot;
    end
  end
    
  methods (Access = public, Static = false)
    function setPerturbation(this, deltaTrans, deltaRot)
      this.deltaTranslation = deltaTrans;
      this.deltaRotation = deltaRot;
    end
    
    function pose = evaluate(this, t)
      pFinal = this.translation+this.deltaTranslation;
      qFinal = Quat2Homo(this.deltaRotation)*this.rotation;
      pose = tom.Pose(struct('p', pFinal, 'q', qFinal));      
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
