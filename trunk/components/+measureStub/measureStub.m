classdef measureStub < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    diagonal
  end
  
  methods (Access=public)
    function this=measureStub(u)
      this=this@measure(u);
      this.sensor=u;
      this.diagonal=false;
      fprintf('\n');
      fprintf('\nmeasureStub::measureStub');
    end
    
    function time=getTime(this,k)
      time=getTime(this.sensor,k);
    end
    
    function status=refresh(this)
      status=refresh(this.sensor);
    end
      
    function flag=isDiagonal(this)
      flag=this.diagonal;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nmeasureStub::findEdges');
      [ka,kb]=getNodeBounds(this.sensor);
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
      fprintf('\nmeasureStub::computeEdgeCost');
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      [pa,qa]=evaluate(x,ta);
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
   
      [pb,qb]=evaluate(x,tb);      
      fprintf('\nx(%f) = < ',tb);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      cost=0;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
