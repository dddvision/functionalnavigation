classdef opticalFlowPDollar < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    diagonal
    ready
  end
  
  methods (Access=public)
    function this=opticalFlowPDollar(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::opticalFlowPDollar');
      this.ready=false;
      [scheme,resource]=strtok(uri,':');
      switch(scheme)
      case 'matlab'
        container=eval(resource(2:end));
        list=listSensors(container,'camera');
        if(~isempty(list))
          this.sensor=getSensor(container,list(1));
          this.diagonal=false;
          this.ready=true;
        end
      end                  
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      time=getTime(this.sensor,k);
    end
    
    function status=refresh(this)
      assert(this.ready);
      status=refresh(this.sensor);
    end
    
    function flag=isDiagonal(this)
      flag=this.diagonal;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::findEdges');
      a=[];
      b=[];      
      if(this.ready)
        ka=first(this.sensor);
        kb=last(this.sensor);
        if(kb>=ka)
          a=ka;
          b=kb;
        end
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::computeEdgeCost');
      assert(this.ready);
      
      ka=first(this.sensor);
      kb=last(this.sensor);
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