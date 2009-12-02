classdef measureStub < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    trajectory
  end
  
  methods (Access=public)
    function this=measureStub(u,x)
      this=this@measure(u,x);
      this.sensor=u;
      this.trajectory=x;
      fprintf('\n');
      fprintf('\nmeasureStub::measureStub');
    end
    
    function this=setTrajectory(this,x)
      this.trajectory=x;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nmeasureStub::findEdges');
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
      fprintf('\nmeasureStub::computeEdgeCost');
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      [pa,qa]=evaluate(this.trajectory,ta);
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
   
      [pb,qb]=evaluate(this.trajectory,tb);      
      fprintf('\nx(%f) = < ',tb);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      cost=0;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
