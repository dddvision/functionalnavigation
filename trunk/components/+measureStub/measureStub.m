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
      pqa=evaluate(x,tmin);
      fprintf('\nx(%f) = < ',tmin);
      fprintf('%f ',pqa);
      fprintf('>');
   
      pqb=evaluate(x,tmax);      
      fprintf('\nx(%f) = < ',tmax);
      fprintf('%f ',pqb);
      fprintf('>');
      
      cost=rand;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
