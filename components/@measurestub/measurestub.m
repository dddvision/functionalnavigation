classdef measurestub < measure
  
  methods
    function this=measurestub(u)
      fprintf('\n');
      fprintf('\nmeasurestub::measurestub');
    end
    
    function cost=evaluate(this,x,tmin)
      fprintf('\n');
      fprintf('\n%s::evaluate',class(this));
      
      [tZero,tmax]=domain(x);
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
