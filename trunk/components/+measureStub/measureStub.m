classdef measureStub < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
  end
  
  methods (Access=public)
    function this=measureStub(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\nmeasureStub::measureStub');
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            list=listSensors(container,'sensor');
            this.sensor=getSensor(container,list(1));
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end 
    end
    
    function status=refresh(this)
      status=refresh(this.sensor);
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
    
    function [a,b]=findEdges(this,kbMin,dMax)
      fprintf('\n');
      fprintf('\nmeasureStub::findEdges');
      a=[];
      b=[];      
      if( dMax>0 )
        ka=max(kbMin-1,first(this.sensor));
        kb=last(this.sensor);
        a=ka:(kb-1);
        b=(ka+1):kb;
      end
    end
        
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nmeasureStub::computeEdgeCost');
      
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
