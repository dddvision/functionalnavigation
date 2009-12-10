classdef opticalFlowPDollar < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    diagonal
  end
  
  methods (Access=public)
    function this=opticalFlowPDollar(u)
      this=this@measure(u);
      this.sensor=u;
      this.diagonal=false;
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::opticalFlowPDollar');
    end
    
    function [ka,kb]=dataDomain(this)
      [ka,kb]=dataDomain(this.sensor);
    end
    
    function time=getTime(this,k)
      time=getTime(this.sensor,k);
    end
    
    function isLocked=lock(this)
      isLocked=lock(this.sensor);
    end
    
    function isUnlocked=unlock(this)
      isUnlocked=unlock(this.sensor);
    end
    
    function flag=isDiagonal(this)
      flag=this.diagonal;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::findEdges');
      [ka,kb]=dataDomain(this.sensor);
      if( ka==kb )
        a=[];
        b=[];
      else
        a=ka;
        b=kb;
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::computeEdgeCost');
      
      [ka,kb]=dataDomain(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));
      
      % get optical flow from cache
      data=opticalFlow1_cache(this,a,b);

      % get corresponding times
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);

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
