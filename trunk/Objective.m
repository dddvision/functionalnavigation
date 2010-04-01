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
      initialTime=waitForData(this);
      description=eval([this.dynamicModelName,'.',this.dynamicModelName,'.getInitialBlockDescription']);
      this.F=cell(popSize,1);
      for k=1:popSize
        initialBlock=generateBlock(description);
        this.F{k}=DynamicModel.factory(this.dynamicModelName,initialTime,initialBlock,this.uri);
      end
      extend(this);
    end
    
    function refresh(this)
      for k=1:numel(this.g)
        refresh(this.g{k});
      end
      extend(this);
    end
  end
  
  methods (Access=private)    
    function initialTime=waitForData(this)
      initialTime=Inf;
      fprintf('\nWaiting for data...');
      while(isinf(initialTime))
        for k=1:numel(this.g)
          refresh(this.g{k});
          if(hasData(this.g{k}))
            initialTime=min(initialTime,getTime(this.g{k},first(this.g{k})));
          end
        end
      end
      fprintf('done');
    end
    
    function extend(this)
      blocksPerSecond=this.F{1}.getUpdateRate;
      if(blocksPerSecond)
        [lastTime,tb]=domain(this.F{1});
        for k=1:numel(this.g)
          if(hasData(this.g{k}))
            lastTime=max(lastTime,getTime(this.g{k},last(this.g{k})));
          end
        end
        oldNumBlocks=getNumExtensionBlocks(this.F{1});
        newNumBlocks=ceil((lastTime-tb)*blocksPerSecond);
        numAppend=newNumBlocks-oldNumBlocks;
        if(newNumBlocks>oldNumBlocks)
          description=this.F{1}.getExtensionBlockDescription;
          K=numel(this.F);
          for k=1:K
            for blk=1:numAppend
              extensionBlock=generateBlock(description);
              appendExtensionBlocks(this.F{k},extensionBlock);
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
