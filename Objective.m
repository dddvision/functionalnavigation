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
    
    function edgeList=findEdges(this,m,kaSpan,kbSpan)
      edgeList=findEdges(this.measure{m},kaSpan,kbSpan);
    end
    
    function cost=computeEdgeCost(this,m,k,edge)
      cost=computeEdgeCost(this.measure{m},this.input(k),edge);
    end
    
    function flag=hasData(this,m)
      flag=hasData(this.measure{m});
    end
    
    function ka=first(this,m)
      ka=first(this.measure{m});
    end
    
    function ka=last(this,m)
      ka=last(this.measure{m});
    end
    
    function time=getTime(this,m,k)
      time=getTime(this.measure{m},k);
    end
    
    function refresh(this)
      [ta,tb]=waitForData(this);
      extend(this,tb);
    end
    
    function cost=computeCostMean(this,kaSpan,kbSpan)
      K=numel(this.input);
      M=numMeasures(this);
      B=double(numExtensionBlocks(this.input(1)));
      allGraphs=cell(K,M+1);

      % build cost graph from prior
      for k=1:K
        Fk=this.input(k);
        cost=sparse([],[],[],B+1,B+1,B+1);
        cost(1,1)=computeInitialBlockCost(Fk);
        for b=uint32(1):uint32(B)
          cost(b,b+1)=computeExtensionBlockCost(Fk,b-1);
        end
        allGraphs{k,1}=cost;
      end

      % build cost graphs from measures
      numEdges=zeros(1,M);
      for m=1:M
        edgeList=findEdges(this,m,kaSpan,kbSpan);
        numEdges(m)=numel(edgeList);
        ka=cat(1,edgeList.first);
        kb=cat(1,edgeList.second);
        for k=1:K
          if(numEdges(m))
            cost=zeros(1,numEdges(m));
            for edge=1:numEdges(m)
              cost(edge)=computeEdgeCost(this,m,k,edgeList(edge));
            end
            base=ka(1);
            span=double(kb(end)-base+1);
            allGraphs{k,1+m}=sparse(double(ka-base+1),double(kb-base+1),cost,span,span,numEdges(m));
          else
            allGraphs{k,1+m}=0;
          end
        end
      end

      % sum costs across graphs for each individual
      cost=zeros(K,1);
      for k=1:K
        for m=1:(M+1)
          costkm=allGraphs{k,m};
          cost(k)=cost(k)+sum(costkm(:));
        end
      end

      % normalize costs by total number of blocks and edges
      cost=cost/(1+B+sum(numEdges));
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
