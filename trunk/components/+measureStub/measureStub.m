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
    
    function cost=evaluate(this,x,tmin)
      fprintf('\n');
      fprintf('\nmeasureStub::evaluate');
      
      [a,b]=domain(this.u);
      tmin=getTime(this.u,a);
      tmax=getTime(this.u,b);
      [pa,qa]=evaluate(x,tmin);
      fprintf('\nx(%f) = < ',tmin);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
   
      [pb,qb]=evaluate(x,tmax);      
      fprintf('\nx(%f) = < ',tmax);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      cost=rand;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
