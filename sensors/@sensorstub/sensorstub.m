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
 
    function bits=getBits(this,tmin)
      bits=this.intrinsicStochastic;
    end
    
    function this=putBits(this,bits,tmin)
      fprintf('\n');
      fprintf('\n%s::putBits',class(this));
      fprintf('\ntmin = %f',tmin);
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.intrinsicStochastic=bits;
    end
 
    function cost=priorCost(this,bits,tmin)
      cost=zeros(size(bits,1),1);
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
      
      cost=1000*rand;
      fprintf('\ncost = %f',cost);
    end
    
    function costPotential=upperBound(this,tmin)
      costPotential=1000;
    end
    
  end
end
