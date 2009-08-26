classdef sensorstub < sensor
  properties (GetAccess=private,SetAccess=private)
    intrinsicStatic
    intrinsicDynamic
  end  
  methods
    function this=sensorstub
      fprintf('\n');
      fprintf('\nsensorstub::sensorstub');
      this.intrinsicStatic=logical(rand(1,8)>=0.5);
      this.intrinsicDynamic=logical(rand(1,30)>=0.5);
    end
 
    function bits=staticGet(this)
      bits=this.intrinsicStatic;
    end
    
    function this=staticPut(this,bits)
      fprintf('\n');
      fprintf('\n%s::staticPut',class(this));
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.intrinsicStatic=bits;
    end
 
    function bits=dynamicGet(this,tmin)
      bits=this.intrinsicDynamic;
    end

    function this=dynamicPut(this,bits,tmin)
      this.intrinsicDynamic=bits;
    end
      
    function cost=priorCost(this,staticBits,dynamicBits,tmin)
      cost=0;
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
      
      c=0.5;
      fprintf('\ncost = %f',c);
    end
    
  end
end
