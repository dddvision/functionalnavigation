classdef measureStub < measure
  
  methods (Access=public)
    function this=measureStub(u,x)
      fprintf('\n');
      fprintf('\nmeasureStub::measureStub');
      this=this@measure(u,x);
    end
    
    function [a,b]=getEdges(this)
      fprintf('\n');
      fprintf('\nmeasureStub::getEdges');
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
      
      cost=rand;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
