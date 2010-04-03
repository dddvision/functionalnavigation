classdef Objective < ObjectiveConfig & handle
  
  properties (GetAccess=public,SetAccess=private)
    F
  end

  properties (GetAccess=private,SetAccess=private)
    measure
  end
  
  methods (Access=public)
    function this=Objective(popSize)
      for k=1:numel(this.measureNames)
        this.measure{k}=Measure.factory(this.measureNames{k},this.uri);
      end
      [ta,tb]=waitForData(this);
      description=eval([this.dynamicModelName,'.',this.dynamicModelName,'.initialBlockDescription']);
      initialBlock=generateBlock(description);
      this.F=DynamicModel.factory(this.dynamicModelName,ta,initialBlock,this.uri);
      for k=2:popSize
        initialBlock=generateBlock(description);
        this.F(k)=DynamicModel.factory(this.dynamicModelName,ta,initialBlock,this.uri);
      end
      extend(this,tb);
    end
    
    function num=numMeasures(this)
      num=numel(this.measure);
    end
    
    function [ka,kb]=findEdges(this,m,kaMin,kbMin)
      [ka,kb]=findEdges(this.measure{m},kaMin,kbMin);
    end
    
    function cost=computeEdgeCost(this,m,k,ka,kb)
      cost=computeEdgeCost(this.measure{m},this.F(k),ka,kb);
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
    
    function cost=computeCostMean(this)
      % HACK: find another way to get these parameters
      kaMaxLag=uint32(100);
      kbMaxLag=uint32(100);

      K=numel(this.F);
      M=numMeasures(this);
      B=double(numExtensionBlocks(this.F(1)));
      allGraphs=cell(K,M+1);

      % build cost graph from prior
      for k=1:K
        Fk=this.F(k);
        cost=sparse([],[],[],B+1,B+1,B+1);
        initialBlock=getInitialBlock(Fk);
        cost(1,1)=computeInitialBlockCost(Fk,initialBlock);
        extensionBlocks=getExtensionBlocks(Fk,uint32(0:(B-1)));
        for b=1:B
          cost(b,b+1)=computeExtensionBlockCost(Fk,extensionBlocks(b));
        end
        allGraphs{k,1}=cost;
      end

      % build cost graphs from measures
      numEdges=zeros(1,M);
      for m=1:M
        lastNode=last(this,m);
        [ka,kb]=findEdges(this,m,lastNode-kaMaxLag,lastNode-kbMaxLag);
        numEdges(m)=numel(ka);
        for k=1:K
          if(numEdges(m))
            cost=zeros(1,numEdges(m));
            for edge=1:numEdges(m)
              cost(edge)=computeEdgeCost(this,m,k,ka(edge),kb(edge));
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
    end
    
    function extend(this,tbNew)
      rate=this.F.updateRate;
      if(rate)
        [ta,tb]=domain(this.F(1));
        oldNumBlocks=numExtensionBlocks(this.F(1));
        newNumBlocks=ceil((tbNew-tb)*rate);
        numAppend=newNumBlocks-oldNumBlocks;
        if(newNumBlocks>oldNumBlocks)
          description=this.F(1).extensionBlockDescription;
          for k=1:numel(this.F)
            for b=1:numAppend
              extensionBlock=generateBlock(description);
              appendExtensionBlocks(this.F(k),extensionBlock);
            end
          end
        end
      end
    end
  end
  
end

function block=generateBlock(description)
  block=struct('logical',logical(rand(1,description.numLogical)>0.5),...
    'uint32',randi([0,4294967295],1,description.numUint32,'uint32'));
end
