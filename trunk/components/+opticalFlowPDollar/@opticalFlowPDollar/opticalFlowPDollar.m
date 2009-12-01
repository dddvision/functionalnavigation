classdef opticalFlowPDollar < measure
  
  methods (Access=public)
    function this=opticalFlowPDollar(u,x)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::opticalFlowPDollar');
      this=this@measure(u,x);
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::findEdges');
      [aa,bb]=domain(this.sensor);
      if( aa==bb )
        a=[];
        b=[];
      else
        a=aa;
        b=bb;
      end
    end
    
    function cost=computeEdgeCost(this,a,b)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::computeEdgeCost');
      
      [aa,bb]=domain(this.sensor);
      assert((b>a)&&(a>=aa)&&(b<=bb));
      
      % get optical flow from cache
      data=opticalFlow1_cache(this,a,b);

      % get corresponding times
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);

      % evaluate sensor position and orientation
      [pa,qa]=evaluate(this.trajectory,ta);
      [pb,qb]=evaluate(this.trajectory,tb);

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
