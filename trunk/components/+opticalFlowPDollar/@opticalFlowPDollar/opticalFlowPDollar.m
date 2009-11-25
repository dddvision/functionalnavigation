classdef opticalFlowPDollar < measure
  
  properties (GetAccess=private,SetAccess=private)
    cameraHandle
  end
  
  methods (Access=public)
    function this=opticalFlowPDollar(cameraHandle)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::opticalFlowPDollar');
      % TODO: get real or simulated data
      this.cameraHandle=cameraHandle;
    end
    
    function [a,b]=getNodes(this)
      [a,b]=domain(this.cameraHandle);
    end
    
    function n=getEdgesForward(this,a,b)
      [aa,bb]=domain(this.cameraHandle);
      if( (b<=a)||(a<aa)||(b>bb) )
        n=uint32([]);
      else
        n=uint32((a+1):b);
      end
    end
    
    function n=getEdgesBackward(this,a,b)
      [aa,bb]=domain(this.cameraHandle);
      if( (b<=a)||(a<aa)||(b>bb) )
        n=uint32([]);
      else
        n=uint32(a:(b-1));
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::computeEdgeCost');
      
      [aa,bb]=domain(this.cameraHandle);
      assert((b>a)&&(a>=aa)&&(b<=bb));
      
      % get optical flow from cache
      data=opticalFlow1_cache(this,a,b);

      % get corresponding times
      ta=getTime(this.cameraHandle,a);
      tb=getTime(this.cameraHandle,b);

      % evaluate sensor position and orientation
      [pa,qa]=evaluate(x,ta);
      [pb,qb]=evaluate(x,tb);

      % convert quaternions to Euler angles
      Ea=Quat2Euler(qa);
      Eb=Quat2Euler(qb);

      % TODO: handle nonlinear and possibly dynamic projections
      testTrajectory.f = 100;
      testTrajectory.Translation = [pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3)];
      testTrajectory.Rotation = [Eb(1)-Ea(1),Eb(2)-Ea(2),Eb(3)-Ea(3)];

      fprintf('\ntranslation = < %f %f %f >',...
        testTrajectory.Translation(1),...
        testTrajectory.Translation(2),...
        testTrajectory.Translation(3));
      fprintf('\nrotation angles = < %f %f %f >',...
        testTrajectory.Rotation(1),...
        testTrajectory.Rotation(2),...
        testTrajectory.Rotation(3));

      % compute the cost
      cost=computecost(data.Vx_OF,data.Vy_OF,testTrajectory);
      fprintf('\ncost = %f',cost);
    end
  end
  
end
