classdef measureStub < measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    ready
  end
  
  methods (Access=public)
    function this=measureStub(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\nmeasureStub::measureStub');
      this.ready=false;
      [scheme,resource]=strtok(uri,':');
      switch(scheme)
      case 'matlab'
        container=eval(resource(2:end));
        list=listSensors(container,'sensor');
        if(~isempty(list))
          this.sensor=getSensor(container,list(1));
          this.ready=true;
        end
      end          
    end
    
    function ka=first(this)
      ka=first(this.sensor);
    end
    
    function ka=last(this)
      ka=last(this.sensor);
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      time=getTime(this.sensor,k);
    end
    
    function status=refresh(this)
      assert(this.ready);
      status=refresh(this.sensor);
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nmeasureStub::findEdges');
      a=[];
      b=[];      
      if(this.ready)
        ka=first(this.sensor);
        kb=last(this.sensor);
        if(kb>=ka)
          a=ka;
          b=kb;
        end
      end
    end
        
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\nmeasureStub::computeEdgeCost');
      assert(this.ready);
      
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
      
      cost=rand;
      fprintf('\ncost = %f',cost);
    end
  end
  
end
