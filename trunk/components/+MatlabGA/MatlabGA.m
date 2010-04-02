classdef MatlabGA < MatlabGA.MatlabGAConfig & Optimizer
  
  properties (GetAccess=private,SetAccess=private)
    M
    bits
    cost
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=MatlabGA
      fprintf('\n\n%s',class(this));
            
      if(this.hasLicense)
        if(~license('test','gads_toolbox'))
          error('Requires license for GADS toolbox -- see MatlabGA configuration options');
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
        this.defaultOptions.PopulationSize=this.popSize;
        this.defaultOptions.EliteCount=1+floor(this.popSize/12);

        % workaround to access stepGA from the gads toolbox
        userPath=pwd;
        cd(fullfile(fileparts(which('ga')),'private'));
        temp=@stepGA;
        cd(userPath);
        this.stepGAhandle=temp;
      end
      
      % create objective
      this.M=Objective(this.popSize);
     
      % initialize dynamic models
      numBits=numInitialBits(this)+numExtensionBits(this)*getNumExtensionBlocks(this.M.F{1});
      this.bits=logical(rand(this.popSize,numBits)>0.5);
      
      % determine initial costs
      objectiveContainer('put',this);
      this.cost=feval(@objectiveContainer,this.bits);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=cat(1,this.M.F{:});
      cEst=this.cost;
    end
    
    function step(this)
      oldNumBlocks=getNumExtensionBlocks(this.M.F{1});
      refresh(this.M);
      newNumBlocks=getNumExtensionBlocks(this.M.F{1});
      if(newNumBlocks>oldNumBlocks)    
        numAppend=newNumBlocks-oldNumBlocks;
        this.bits=[this.bits,logical(rand(this.popSize,numAppend*numExtensionBits(this))>0.5)];
      end
      if(this.hasLicense)
        nvars=size(this.bits,2);
        nullstate=struct('FunEval',0);
        objectiveContainer('put',this);
        [this.cost,this.bits]=feval(this.stepGAhandle,this.cost,this.bits,this.defaultOptions,nullstate,nvars,@objectiveContainer);
        putBits(this);
      else
        bad=find(this.cost>1.1*min(this.cost));
        this.bits(bad,:)=logical(rand(numel(bad),size(this.bits,2))>0.5);
        putBits(this);
      end
    end
  end
  
  methods (Access=private)
    % vectorized objective function
    function cost=objective(this,bits)
      this.bits=bits;
      putBits(this);
      numIndividuals=numel(this.M.F);
      numMeasures=numel(this.M.g);
      allGraphs=cell(numIndividuals,numMeasures+1);
      numEB=double(getNumExtensionBlocks(this.M.F{1}));
      numEB1=numEB+1;
      numEdges=zeros(1,numMeasures);
      for k=1:numIndividuals
        % build cost graph from dynamic model
        Fk=this.M.F{k};
        cost=sparse([],[],[],numEB1,numEB1,numEB1);
        initialBlock=getInitialBlock(Fk);
        cost(1,1)=computeInitialBlockCost(Fk,initialBlock);
        extensionBlocks=getExtensionBlocks(Fk,uint32(0:(numEB-1)));
        for blk=1:numEB
          cost(blk,blk+1)=computeExtensionBlockCost(Fk,extensionBlocks(blk));
        end
        allGraphs{k,1}=cost;

        % build cost graphs from measures
        for m=1:numMeasures
          gm=this.M.g{m};
          if(k==1)
            [a,b]=findEdges(gm,uint32(0),last(gm)-this.dMax);
            numEdges(m)=numel(a);
          end
          if(numEdges(m))
            cost=zeros(1,numEdges(m));
            for edge=1:numEdges(m)
              cost(edge)=computeEdgeCost(gm,Fk,a(edge),b(edge));
            end
            base=a(1);
            span=double(b(end)-base+1);
            allGraphs{k,1+m}=sparse(double(a-base+1),double(b-base+1),cost,span,span,numEdges(m));
          else
            allGraphs{k,1+m}=0;
          end
        end
      end

      % sum costs across graphs for each individual
      cost=zeros(numIndividuals,1);
      for k=1:numIndividuals
        for m=1:(numMeasures+1)
          costkm=allGraphs{k,m};
          cost(k)=cost(k)+sum(costkm(:));
        end
      end

      % normalize costs by total number of blocks and edges
      cost=cost/(1+numEB+sum(numEdges));
    end
    
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
      n1=this.M.F{1}.initialBlockDescription.numLogical;
      n2=n1+32*this.M.F{1}.initialBlockDescription.numUint32;
      initialBlock=struct('logical',b(1:n1),'uint32',bits2uints(b((n1+1):n2)));
      n3=this.M.F{1}.extensionBlockDescription.numLogical;
      n4=n3+32*this.M.F{1}.extensionBlockDescription.numUint32;
      extensionBlocks=struct('logical',{},'uint32',{});
      numLeftover=size(this.bits,2)-n2;
      numEBits=n3+n4;
      if(numEBits)
        for blk=1:(numLeftover/numEBits)
          extensionBlocks(blk)=struct('logical',b((n2+uint32(1)):(n2+n3)),...
            'uint32',bits2uints(b((n2+n3+uint32(1)):(n2+n4))));
          n2=n2+n4;
        end
      end
    end
   
    function b=numInitialBits(this)
      b=this.M.F{1}.initialBlockDescription.numLogical+32*this.M.F{1}.initialBlockDescription.numUint32;
    end

    function b=numExtensionBits(this)
      b=this.M.F{1}.extensionBlockDescription.numLogical+32*this.M.F{1}.extensionBlockDescription.numUint32;
    end
    
    function putBits(this)
      for k=1:numel(this.M.F)
        [initialBlock,extensionBlocks]=getBlocks(this,k);
        setInitialBlock(this.M.F{k},initialBlock);
        if(~isempty(extensionBlocks))
          setExtensionBlocks(this.M.F{k},uint32(0:(numel(extensionBlocks)-1)),extensionBlocks);
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

function varargout=objectiveContainer(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    varargout{1}=objective(this,bits);
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
