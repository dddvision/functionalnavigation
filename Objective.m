classdef Objective < handle
  
  properties (GetAccess=public,SetAccess=private)
    input
  end

  properties (GetAccess=private,SetAccess=private)
    measure
    dynamicModelName
    uri
  end
  
  methods (Access=public)
    function this=Objective(dynamicModelName,measureNames,uri)
      assert(isa(dynamicModelName,'char'));
      assert(isa(measureNames{1},'char'));
      assert(isa(uri,'char'));
      this.dynamicModelName=dynamicModelName;
      this.uri=uri;
      for m=1:numel(measureNames)
        this.measure{m}=Measure.factory(measureNames{m},uri);
      end
      [ta,tb]=waitForData(this);
      this.input=DynamicModel.factory(dynamicModelName,ta,uri);
      L=generateLogical(numInitialLogical(this.input));
      for p=uint32(1:numel(L))
        setInitialLogical(this.input,p-1,L(p));
      end
      U=generateUint32(numInitialUint32(this.input));
      for p=uint32(1:numel(U))
        setInitialUint32(this.input,p-1,U(p));
      end
      extend(this,tb);
    end
    
    function addInput(this)
      interval=domain(this.input(1));
      this.input(end+1)=DynamicModel.factory(this.dynamicModelName,interval.first,this.uri);
      L=generateLogical(numInitialLogical(this.input(end)));
      for p=uint32(1:numel(L))
        setInitialLogical(this.input(end),p-1,L(p));
      end
      U=generateUint32(numInitialUint32(this.input(end)));
      for p=uint32(1:numel(U))
        setInitialUint32(this.input(end),p-1,U(p));
      end
      extend(this,interval.second);
    end
    
    function num=numMeasures(this)
      num=numel(this.measure);
    end
    
    function edgeList=findEdges(this,m,k,naSpan,nbSpan)
      edgeList=findEdges(this.measure{m},this.input(k),naSpan,nbSpan);
    end
    
    function cost=computeEdgeCost(this,m,k,graphEdge)
      cost=computeEdgeCost(this.measure{m},this.input(k),graphEdge);
    end
    
    function flag=hasData(this,m)
      flag=hasData(this.measure{m});
    end
    
    function na=first(this,m)
      na=first(this.measure{m});
    end
    
    function na=last(this,m)
      na=last(this.measure{m});
    end
    
    function time=getTime(this,m,n)
      time=getTime(this.measure{m},n);
    end
    
    function refresh(this)
      [ta,tb]=waitForData(this);
      extend(this,tb);
    end
  end
  
  methods (Access=private)    
    function [ta,tb]=waitForData(this)
      ta=Inf;
      tb=-Inf;
      while(isinf(ta))
        for m=1:numel(this.measure)
          gm=this.measure{m};
          refresh(gm);
          if(hasData(gm))
            ta=min(ta,getTime(gm,first(gm)));
            tb=max(tb,getTime(gm,last(gm)));
          end
        end
      end
      ta=WorldTime(ta);
      tb=WorldTime(tb);
    end
    
    function extend(this,tbNew)
      for k=1:numel(this.input)
        Fk=this.input(k);
        numLogical=numExtensionLogical(Fk);
        numUint32=numExtensionUint32(Fk);
        interval=domain(Fk);
        while(interval.second<tbNew)
          extend(Fk);
          b=numExtensionBlocks(Fk); % depends on one-based index
          L=generateLogical(numLogical);
          for p=uint32(1):uint32(numel(L))
            setExtensionLogical(Fk,b-1,p-1,L(p));
          end
          U=generateUint32(numUint32);
          for p=uint32(1):uint32(numel(U))
            setExtensionUint32(Fk,b-1,p-1,U(p));
          end
          interval=domain(Fk);
        end
      end
    end
  end
  
end

function v=generateLogical(num)
  v=logical(rand(1,num)>0.5);
end

function v=generateUint32(num)
  v=randi([0,4294967295],1,num,'uint32');
end
