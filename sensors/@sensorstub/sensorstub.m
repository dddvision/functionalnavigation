classdef sensorstub < sensor
  properties (GetAccess=private,SetAccess=private)
    intrinsicStochastic
  end  
  methods
    function this=sensorstub
      fprintf('\n');
      fprintf('\nsensorstub::sensorstub');
      this.intrinsicStochastic=logical(rand(1,30)>=0.5);
    end
 
    function bits=dynamicGet(this,tmin)
      bits=this.intrinsicStochastic;
    end
    
    function this=dynamicPut(this,bits,tmin)
      fprintf('\n');
      fprintf('\n%s::dynamicPut',class(this));
      fprintf('\ntmin = %f',tmin);
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.intrinsicStochastic=bits;
    end
 
    function cost=priorCost(this,bits,tmin)
      cost=zeros(size(bits,1),1);
    end
    
    function c=evaluate(this,x,tmin)
      fprintf('\n');
      fprintf('\n%s::evaluate',class(this));
      
      pqa=evaluate(x,tmin);
      fprintf('\nx(%f) = < ',tmin);
      fprintf('%f ',pqa);
      fprintf('>');
      
      [tZero,tmax]=domain(x);
      
      pqb=evaluate(x,tmax);      
      fprintf('\nx(%f) = < ',tmax);
      fprintf('%f ',pqb);
      fprintf('>');
      
      c=rand;
      fprintf('\ncost = %f',c);
    end
    
  end
end
