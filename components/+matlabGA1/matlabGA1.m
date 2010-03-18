classdef matlabGA1 < matlabGA1.matlabGA1Config & optimizer
  
  properties (GetAccess=private,SetAccess=private)
    F
    g
    bits
    cost
    initialBlockDescription
    extensionBlockDescription
    blocksPerSecond
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=matlabGA1(dynamicModelName,measureNames,uri)  
      this=this@optimizer(dynamicModelName,measureNames,uri);
      fprintf('\n\n%s',class(this));
      
      if(this.hasLicense)
        if(~license('test','gads_toolbox'))
          error('Requires license for GADS toolbox -- see matlabGA1 configuration options');
        end
        this.defaultOptions = gaoptimset;
        this.defaultOptions.PopulationType = 'bitstring';
        this.defaultOptions.PopInitRange = [0;1];
        this.defaultOptions.CrossoverFraction = this.crossoverFraction;
        this.defaultOptions.MigrationDirection = 'forward';
        this.defaultOptions.MigrationInterval = inf;
        this.defaultOptions.MigrationFraction = 0;
        this.defaultOptions.Generations = 1;
        this.defaultOptions.TimeLimit = inf;
        this.defaultOptions.FitnessLimit = -inf;
        this.defaultOptions.StallGenLimit = inf;
        this.defaultOptions.StallTimeLimit = inf;
        this.defaultOptions.TolFun = 0;
        this.defaultOptions.TolCon = 0;
        this.defaultOptions.CreationFcn = @gacreationuniform;
        this.defaultOptions.CreationFcnArgs = {};
        this.defaultOptions.FitnessScalingFcn = @fitscalingprop;
        this.defaultOptions.FitnessScalingFcnArgs = {};
        this.defaultOptions.SelectionFcn = @selectionstochunif;
        this.defaultOptions.SelectionFcnArgs = {};
        this.defaultOptions.CrossoverFcn = @crossoversinglepoint;
        this.defaultOptions.CrossoverFcnArgs = {};
        this.defaultOptions.MutationFcn = @mutationuniform;
        this.defaultOptions.MutationFcnArgs = {this.mutationRatio};
        this.defaultOptions.Vectorized = 'on';
        this.defaultOptions.LinearConstr.type = 'unconstrained';
        this.defaultOptions.PopulationSize=this.popSizeDefault;
        this.defaultOptions.EliteCount=1+floor(this.popSizeDefault/12);

        % workaround to access stepGA from the gads toolbox
        userPath=pwd;
        cd(fullfile(fileparts(which('ga')),'private'));
        temp=@stepGA;
        cd(userPath);
        this.stepGAhandle=temp;
      end  

      % process dynamic model input description
      this.initialBlockDescription=eval([dynamicModelName,'.',dynamicModelName,'.getInitialBlockDescription']);
      this.extensionBlockDescription=eval([dynamicModelName,'.',dynamicModelName,'.getExtensionBlockDescription']);
      this.blocksPerSecond=eval([dynamicModelName,'.',dynamicModelName,'.getUpdateRate']);

      % initialize dynamic models
      K=this.popSizeDefault;
      this.bits=logical(rand(K,numInitialBits(this))>0.5);
      this.F=cell(K,1);
      for k=1:K
        initialBlock=getBlocks(this,k);
        this.F{k}=unwrapComponent(dynamicModelName,uri,this.referenceTime,initialBlock);
      end
      
      % initialize measures
      K=numel(measureNames);
      this.g=cell(K,1);
      for k=1:K
        this.g{k}=unwrapComponent(measureNames{k},uri);
      end
      refreshAll(this);
      
      % determine initial costs
      objective('put',this);
      this.cost=feval(@objective,this.bits);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=cat(1,this.F{:});
      cEst=this.cost;
    end
    
    function step(this)
      refreshAll(this);
      
      if(this.hasLicense)
        nvars=size(this.bits,2);
        nullstate=struct('FunEval',0);
        [this.cost,this.bits]=feval(this.stepGAhandle,this.cost,this.bits,this.defaultOptions,nullstate,nvars,@objective);
        putBits(this);
      else
        bad=find(this.cost>1.1*min(this.cost));
        this.bits(bad,:)=logical(rand(numel(bad),size(this.bits,2))>0.5);
        putBits(this);
      end
    end
  end
  
  methods (Access=private)
    % bits are packed in the following order:
    % initial logical
    % initial uint32
    % extension 1 logical
    % extension 1 uint32
    % extension 2 logical
    % extension 2 uint32
    % ...
    function [initialBlock,extensionBlocks]=getBlocks(this,k)
      b=this.bits(k,:);
      n1=this.initialBlockDescription.numLogical;
      n2=n1+32*this.initialBlockDescription.numUint32;
      initialBlock=struct('logical',b(1:n1),'uint32',bits2uints(b((n1+1):n2)));
      n3=this.extensionBlockDescription.numLogical;
      n4=n3+32*this.extensionBlockDescription.numUint32;
      extensionBlocks=struct('logical',{},'uint32',{});
      numLeftover=size(this.bits,2)-n2;
      if(numLeftover)
        for blk=1:(numExtensionBits(this)/numLeftover)
          extensionBlocks(blk)=struct('logical',b((n2+uint32(1)):(n2+n3)),...
            'uint32',bits2uints(b((n2+n3+uint32(1)):(n2+n4))));
          n2=n2+n4;
        end
      end
    end

    % refresh measures and extend dynamic models
    function refreshAll(this)
      lastTime=this.referenceTime;
      for k=1:numel(this.g)
        refresh(this.g{k});
        if(hasData(this.g{k}))
          lastTime=max(lastTime,getTime(this.g{k},last(this.g{k})));
        end
      end
      [ta,tb]=domain(this.F{1});
      numNewBlocks=ceil((lastTime-tb)*this.blocksPerSecond);
      numNewBits=numNewBlocks*numExtensionBits(this);
      K=numel(this.F);
      this.bits=[this.bits,logical(rand(K,numNewBits)>0.5)];
      numOldBlocks=getNumExtensionBlocks(this.F{k});
      for k=1:K
        [initialBlock,extensionBlocks]=getBlocks(this,k);
        if(numNewBlocks>numOldBlocks)
          appendExtensionBlocks(this.F{k},extensionBlocks((numOldBlocks+1):end));
        end
      end
    end
   
    function b=numInitialBits(this)
      b=this.initialBlockDescription.numLogical+32*this.initialBlockDescription.numUint32;
    end

    function b=numExtensionBits(this)
      b=this.extensionBlockDescription.numLogical+32*this.extensionBlockDescription.numUint32;
    end
    
    function putBits(this)
      for k=1:numel(this.F)
        [initialBlock,extensionBlocks]=getBlocks(this,k);
        setInitialBlock(this.F{k},initialBlock);
        if(~isempty(extensionBlocks))
          setExtensionBlocks(this.F{k},uint32(0:(numel(extensionBlocks)-1)),extensionBlocks);
        end
      end
    end
  end
end

% bits = logical, 1-by-N
function uints=bits2uints(bits)
  bits=reshape(bits,[32,numel(bits)/32]);
  pow=pow2(31:-1:0);
  uints=uint32(sum(pow*bits,1));
end
 
% uints = uint32 1-by-N
% function bits=uints2bits(uints)
%   bits=rem(floor(transpose(uints)*pow2(-31:0)),2);
%   bits=bits(:);
% end

% Objective function that stores an objective object instance
function varargout=objective(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    this.bits=bits;
    putBits(this);
    numIndividuals=numel(this.F);
    numGraphs=numel(this.g);
    allGraphs=cell(numIndividuals,numGraphs+1);
    for ind=1:numIndividuals
      indF=this.F{ind};

      % build cost graph from dynamic model
      numEB=double(getNumExtensionBlocks(indF));
      numEB1=numEB+1;
      cost=sparse([],[],[],numEB1,numEB1,numEB1);
      [initialBlock,extensionBlocks]=getBlocks(this,ind);
      cost(1,1)=computeInitialBlockCost(indF,initialBlock);
      for blk=1:numEB
        cost(blk,blk+1)=computeExtensionBlockCost(indF,extensionBlocks(blk));
      end
      allGraphs{ind,1}=cost;
      
      % build cost graphs from measures
      for graph=1:numGraphs
        graphG=this.g{graph};
        if(ind==1)
          [a,b]=findEdges(graphG,uint32(0),last(graphG)-this.dMax);
          numEdges=numel(a);
        end
        if(numEdges>0)
          cost=zeros(1,numEdges);
          for edge=1:numEdges
            cost(edge)=computeEdgeCost(graphG,indF,a(edge),b(edge));
          end
          base=a(1);
          span=double(b(end)-base+1);
          allGraphs{ind,1+graph}=sparse(double(a-base+1),double(b-base+1),cost,span,span,numEdges);
        else
          allGraphs{ind,1+graph}=0;
        end
      end
    end
    
    % sum costs across graphs for each individual
    cost=zeros(numIndividuals,1);
    for m=1:numIndividuals
      for n=1:(numGraphs+1)
        costmn=allGraphs{m,n};
        cost(m)=cost(m)+sum(costmn(:));
      end
    end
    varargout{1}=cost;
    
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
