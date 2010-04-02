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
