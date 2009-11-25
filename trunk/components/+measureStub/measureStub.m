classdef measureStub < measure
  
  properties (GetAccess=private,SetAccess=private)
    u
  end  
  
  methods (Access=public)
    function this=measureStub(dataobj)
      fprintf('\n');
      fprintf('\nmeasureStub::measureStub');
      this.u=dataobj;
    end
    
    function [a,b]=getNodes(this)
      [a,b]=domain(this.u);
    end
    
    function n=getEdgesForward(this,a,b)
      [aa,bb]=domain(this.u);
      if( (b<=a)||(a<aa)||(b>bb) )
        n=uint32([]);
      else
        n=uint32((a+1):b);
      end
    end
    
    function n=getEdgesBackward(this,a,b)
      [aa,bb]=domain(this.u);
      if( (b<=a)||(a<aa)||(b>bb) )
        n=uint32([]);
      else
        n=uint32(a:(b-1));
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nmeasureStub::computeEdgeCost');
      
      ta=getTime(this.u,a);
      tb=getTime(this.u,b);
      [pa,qa]=evaluate(x,ta);
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
   
      [pb,qb]=evaluate(x,tb);      
      fprintf('\nx(%f) = < ',tb);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      cost=rand;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
