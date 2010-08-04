% NOTES
% The MATLAB Genetic Algorithm converts between blocks and bit strings
% Each bit string is packed in the following order:
%   initial logical
%   initial uint32
%   extension 1 logical
%   extension 1 uint32
%   extension 2 logical
%   extension 2 uint32
%   ...
classdef MatlabGA < MatlabGA.MatlabGAConfig & Optimizer
  
  properties (GetAccess=private,SetAccess=private)
    nSpan
    objective
    cost
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=MatlabGA(dynamicModelName,measureNames,uri)
      this=this@Optimizer(dynamicModelName,measureNames,uri);
            
      if(~license('test','gads_toolbox'))
        error('Requires license for GADS toolbox -- see MatlabGA configuration options');
      end
      this.defaultOptions = gaoptimset;
      this.defaultOptions.PopulationType = 'bitstring';
      this.defaultOptions.PopInitRange = [0;1];
      this.defaultOptions.MigrationDirection = 'forward';
      this.defaultOptions.MigrationInterval = Inf;
      this.defaultOptions.MigrationFraction = 0;
      this.defaultOptions.Generations = 1;
      this.defaultOptions.TimeLimit = Inf;
      this.defaultOptions.FitnessLimit = -Inf;
      this.defaultOptions.StallGenLimit = Inf;
      this.defaultOptions.StallTimeLimit = Inf;
      this.defaultOptions.TolFun = 0;
      this.defaultOptions.TolCon = 0;
      this.defaultOptions.Vectorized = 'on';
      this.defaultOptions.LinearConstr.type = 'unconstrained';
      this.defaultOptions.EliteCount = 1+floor(this.PopulationSize/12);

      this.defaultOptions.PopulationSize = this.PopulationSize;
      this.defaultOptions.CrossoverFraction = this.CrossoverFraction;
      this.defaultOptions.CreationFcn = this.CreationFcn;
      this.defaultOptions.CreationFcnArgs = this.CreationFcnArgs;
      this.defaultOptions.FitnessScalingFcn = this.FitnessScalingFcn;
      this.defaultOptions.FitnessScalingFcnArgs = this.FitnessScalingFcnArgs;
      this.defaultOptions.SelectionFcn = this.SelectionFcn;
      this.defaultOptions.SelectionFcnArgs = this.SelectionFcnArgs;
      this.defaultOptions.CrossoverFcn = this.CrossoverFcn;
      this.defaultOptions.CrossoverFcnArgs = this.CrossoverFcnArgs;
      this.defaultOptions.MutationFcn = this.MutationFcn;
      this.defaultOptions.MutationFcnArgs = this.MutationFcnArgs;

      % workaround to access stepGA from the gads toolbox
      userPath=pwd;
      cd(fullfile(fileparts(which('ga')),'private'));
      temp=@stepGA;
      cd(userPath);
      this.stepGAhandle=temp;
      
      % compute span associated with a maximum number of graph edges (edges<=span*(span+1)/2)
      this.nSpan=uint32(floor(-0.5+sqrt(0.25+2*this.maxEdges)));
      
      % instantiate the default objective
      this.objective=Objective(dynamicModelName,measureNames,uri);
      
      % add inputs to the objective
      for k=numel(this.objective.input):this.PopulationSize
        addInput(this.objective);
      end
      
      % determine initial costs
      bits=getBits(this.objective);
      objectiveContainer('put',this);
      this.cost=feval(@objectiveContainer,bits);
    end
    
    function num=numResults(this)
      num=numel(this.objective.input);
    end
       
    function xEst=getTrajectory(this,k)
      xEst=this.objective.input(k+1);
    end
    
    function cEst=getCost(this,k)
      cEst=this.cost(k+1);
    end
    
    function step(this)
      refresh(this.objective);
      bits=getBits(this.objective);
      nvars=size(bits,2);
      nullstate=struct('FunEval',0);
      objectiveContainer('put',this);
      [this.cost,bits]=feval(this.stepGAhandle,this.cost,bits,...
        this.defaultOptions,nullstate,nvars,@objectiveContainer);
      putBits(this.objective,bits);
    end
  end
end

function [K,B,n1,n2,n3,n4]=analyzeStructure(objective)
  x=objective.input(1);
  K=numel(objective.input);
  B=numExtensionBlocks(x);
  n1=numInitialLogical(x);
  n2=numInitialUint32(x);
  n3=numExtensionLogical(x);
  n4=numExtensionUint32(x);
end

function bits=getBits(objective)
  [K,B,n1,n2,n3,n4]=analyzeStructure(objective);
  bits=false(K,n1+n2+B*(n3+n4));
  p1=uint32(1):n1;
  p2=uint32(1):n2;
  p3=uint32(1):n3;
  p4=uint32(1):n4;
  pU=uint32(1):uint32(32);
  bB=uint32(1):uint32(B);
  for k=1:K
    Fk=objective.input(k);
    base=uint32(0);
    for p=p1
      bits(k,base+p)=getInitialLogical(Fk,p-1);
    end
    base=base+n1;
    for p=p2
      bits(k,base+pU)=uints2bits(getInitialUint32(Fk,p-1));
      base=base+uint32(32);
    end
    for b=bB
      for p=p3
        bits(k,base+p)=getExtensionLogical(Fk,b-1,p-1);
      end
      base=base+n3;
      for p=p4
        bits(k,base+pU)=uints2bits(getExtensionUint32(Fk,b-1,p-1));
        base=base+uint32(32);
      end
    end
  end
end

function putBits(objective,bits)
  [K,B,n1,n2,n3,n4]=analyzeStructure(objective);
  p1=uint32(1):n1;
  p2=uint32(1):n2;
  p3=uint32(1):n3;
  p4=uint32(1):n4;
  pU=uint32(1):uint32(32);
  bB=uint32(1):uint32(B);
  for k=1:K
    Fk=objective.input(k);
    base=uint32(0);
    for p=p1
      setInitialLogical(Fk,p-1,bits(k,base+p));
    end
    base=base+n1;
    for p=p2
      setInitialUint32(Fk,p-1,bits2uints(bits(k,base+pU)));
      base=base+uint32(32);
    end
    for b=bB
      for p=p3
        setExtensionLogical(Fk,b-1,p-1,bits(k,base+p));
      end
      base=base+n3;
      for p=p4
        setExtensionUint32(Fk,b-1,p-1,bits2uints(bits(k,base+pU)));
        base=base+uint32(32);
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
function bits=uints2bits(uints)
  bits=rem(floor(transpose(pow2(-31:0))*double(uints)),2);
  bits=bits(:);
end

function cost=computeCostMean(objective,kBest,naSpan,nbSpan)
  K=numel(objective.input);
  M=numMeasures(objective);
  B=double(numExtensionBlocks(objective.input(1)));
  allGraphs=cell(K,M+1);

  % build cost graph from prior
  for k=1:K
    Fk=objective.input(k);
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
    edgeList=findEdges(objective,m,kBest,naSpan,nbSpan);
    numEdges(m)=numel(edgeList);
    na=cat(1,edgeList.first);
    nb=cat(1,edgeList.second);
    for k=1:K
      if(numEdges(m))
        cost=zeros(1,numEdges(m));
        for graphEdge=1:numEdges(m)
          cost(graphEdge)=computeEdgeCost(objective,m,k,edgeList(graphEdge));
        end
        base=na(1);
        span=double(nb(end)-base+1);
        allGraphs{k,1+m}=sparse(double(na-base+1),double(nb-base+1),cost,span,span,numEdges(m));
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

function varargout=objectiveContainer(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    kBest=find(this.cost==min(this.cost),1,'first');
    putBits(this.objective,bits);
    varargout{1}=computeCostMean(this.objective,kBest,this.nSpan,this.nSpan);
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
