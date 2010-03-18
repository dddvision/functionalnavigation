classdef measureStub < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
  end
  
  methods (Access=public)
    function this=measureStub(uri)
      this=this@measure(uri);
      fprintf('\n\n%s',class(this));
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            list=listSensors(container,'sensor');
            this.sensor=getSensor(container,list(1));
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end 
    end
    
    function refresh(this)
      refresh(this.sensor);
    end
    
    function flag=hasData(this)
      flag=hasData(this.sensor);
    end
    
    function ka=first(this)
      ka=first(this.sensor);
    end
    
    function ka=last(this)
      ka=last(this.sensor);
    end
    
    function time=getTime(this,k)
      time=getTime(this.sensor,k);
    end
    
    function [a,b]=findEdges(this,kaMin,kbMin)
      assert(isa(kaMin,'uint32'));
      assert(isa(kbMin,'uint32'));
      assert(numel(kaMin)==1);
      assert(numel(kbMin)==1);
      if(hasData(this.sensor))
        kaMin=max([first(this.sensor),kaMin,kbMin-uint32(1)]);
        kaMax=last(this.sensor)-uint32(1);
        a=kaMin:kaMax;
        b=a+uint32(1);
      else
        a=uint32([]);
        b=uint32([]);
      end
    end
        
    function cost=computeEdgeCost(this,x,a,b)
      assert(isa(x,'trajectory'));
      assert(isa(a,'uint32'));
      assert(isa(b,'uint32'));
      assert(numel(x)==1);
      assert(numel(a)==1);
      assert(numel(b)==1);
      assert(hasData(this.sensor));
      ka=first(this.sensor);
      kb=last(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      
      [pa,qa]=evaluate(x,ta);
      [pb,qb]=evaluate(x,tb);  
      
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
    
      fprintf('\nx(%f) = < ',tb);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      cost=rand;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
