classdef Objective < ObjectiveConfig
  
  properties (GetAccess=public,SetAccess=private)
    F
    g
  end
  
  methods (Access=public)
    function this=Objective(popSize)
      numMeasures=numel(this.measureNames);
      this.g=cell(numMeasures,1);
      for k=1:numMeasures
        this.g{k}=Measure.factory(this.measureNames{k},this.uri);
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
        for k=1:numel(this.g)
          gk=this.g{k};
          refresh(gk);
          if(hasData(gk))
            ta=min(ta,getTime(gk,first(gk)));
            tb=max(tb,getTime(gk,last(gk)));
          end
        end
      end
    end
    
    function extend(this,tbNew)
      rate=this.F(1).updateRate;
      if(rate)
        [ta,tb]=domain(this.F(1));
        oldNumBlocks=getNumExtensionBlocks(this.F(1));
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
