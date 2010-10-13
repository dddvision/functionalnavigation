classdef TrajectoryPerturbation < Trajectory

  properties (GetAccess=private,SetAccess=private)
      %the change in 
      translation
      rotation
      deltaTranslation
      deltaRotation
  end
    
  methods (Access=public)
    % foward,right,down   -   quat
    % base trajectory and rotation (ie ground truth)
    function this = TrajectoryPerturbation(trans, rot)
      this.translation = trans;
      this.rotation = rot;
    end
    
    function setPerturbation(deltaTrans,deltaRot)
      this.deltaTranslation = deltaTrans;
      this.deltaRotation = deltaRot;
    end
    
    
    function pose=evaluate(this,t)
      finalQuat = zeroes(4);
      finalQuat(1) =  this.deltaRotation(1)*this.rotation(1) ...
                    - this.deltaRotation(2)*this.rotation(2) ...
                    - this.deltaRotation(3)*this.rotation(3) ...
                    - this.deltaRotation(4)*this.rotation(4);
      finalQuat(2) =  this.deltaRotation(2)*this.rotation(1) ...
                    + this.deltaRotation(1)*this.rotation(2) ...
                    + this.deltaRotation(3)*this.rotation(4) ...
                    - this.deltaRotation(4)*this.rotation(3);
      finalQuat(3) =  this.deltaRotation(1)*this.rotation(3) ...
                    - this.deltaRotation(2)*this.rotation(4) ...
                    + this.deltaRotation(3)*this.rotation(1) ...
                    + this.deltaRotation(4)*this.rotation(2);
      finalQuat(4) =  this.deltaRotation(1)*this.rotation(4) ...
                    + this.deltaRotation(2)*this.rotation(3) ...
                    - this.deltaRotation(3)*this.rotation(2) ...
                    + this.deltaRotation(4)*this.rotation(1);

      newPose = struct(  'p', this.translation+this.deltaTranslation, ...
                         'q', finalQuat);
      pose = Pose(newPose);
      
    end
  end
  
end
