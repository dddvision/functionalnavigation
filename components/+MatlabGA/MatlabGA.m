classdef MatlabGA < MatlabGA.MatlabGAConfig & Optimizer
  
  properties (GetAccess=private,SetAccess=private)
    objective
    bits
    cost
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=MatlabGA
            
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
      this.objective=Objective(this.popSize);
     
      % initialize dynamic models
      numBits=numInitialBits(this)+numExtensionBits(this)*numExtensionBlocks(this.objective.F(1));
      this.bits=logical(rand(this.popSize,numBits)>0.5);
      
      % determine initial costs
      objectiveContainer('put',this);
      this.cost=feval(@objectiveContainer,this.bits);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=this.objective.F;
      cEst=this.cost;
    end
    
    function step(this)
      oldNumBlocks=numExtensionBlocks(this.objective.F(1));
      refresh(this.objective);
      newNumBlocks=numExtensionBlocks(this.objective.F(1));
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
    function cost=simpleObjective(this,bits)
      this.bits=bits;
      putBits(this);
      K=numel(this.objective.F);
      M=numMeasures(this.objective);
      B=double(numExtensionBlocks(this.objective.F(1)));
      allGraphs=cell(K,M+1);
      
      % build cost graph from prior
      for k=1:K
        Fk=this.objective.F(k);
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
        lastNode=last(this.objective,m);
        [ka,kb]=findEdges(this.objective,m,uint32(0),lastNode-this.dMax);
        numEdges(m)=numel(ka);
        for k=1:K
          if(numEdges(m))
            cost=zeros(1,numEdges(m));
            for edge=1:numEdges(m)
              cost(edge)=computeEdgeCost(this.objective,m,k,ka(edge),kb(edge));
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
      n1=this.objective.F(1).initialBlockDescription.numLogical;
      n2=n1+32*this.objective.F(1).initialBlockDescription.numUint32;
      initialBlock=struct('logical',b(1:n1),'uint32',bits2uints(b((n1+1):n2)));
      n3=this.objective.F(1).extensionBlockDescription.numLogical;
      n4=n3+32*this.objective.F(1).extensionBlockDescription.numUint32;
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
      b=this.objective.F(1).initialBlockDescription.numLogical+32*this.objective.F(1).initialBlockDescription.numUint32;
    end

    function b=numExtensionBits(this)
      b=this.objective.F(1).extensionBlockDescription.numLogical+32*this.objective.F(1).extensionBlockDescription.numUint32;
    end
    
    function putBits(this)
      for k=1:numel(this.objective.F)
        [initialBlock,extensionBlocks]=getBlocks(this,k);
        setInitialBlock(this.objective.F(k),initialBlock);
        if(~isempty(extensionBlocks))
          setExtensionBlocks(this.objective.F(k),uint32(0:(numel(extensionBlocks)-1)),extensionBlocks);
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
    varargout{1}=simpleObjective(this,bits);
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
