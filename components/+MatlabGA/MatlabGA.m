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
    nIL
    nIU
    nEL
    nEU
    iIL
    iIU
    iEL
    iEU
    iU
    dynamicModel
    measure
    cost
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=MatlabGA(dynamicModel,measure)
      this=this@Optimizer(dynamicModel,measure);
          
      % set initial options for the GADS toolbox
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
      this.defaultOptions.EliteCount = 1+floor(numel(dynamicModel)/12);
      this.defaultOptions.PopulationSize = numel(dynamicModel);
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

      % copy input argument handles
      this.dynamicModel=dynamicModel;
      this.measure=measure;
      
      % get parameter structure
      this.nIL=numInitialLogical(dynamicModel(1));
      this.nIU=numInitialUint32(dynamicModel(1));
      this.nEL=numExtensionLogical(dynamicModel(1));
      this.nEU=numExtensionUint32(dynamicModel(1));
      this.iIL=uint32(1):this.nIL;
      this.iIU=uint32(1):this.nIU;
      this.iEL=uint32(1):this.nEL;
      this.iEU=uint32(1):this.nEU;
      this.iU=uint32(1):uint32(32);
      
      % randomize initial parameters
      for k=1:numel(this.dynamicModel)
        L=randLogical(this.nIL);
        for p=this.iIL
          setInitialLogical(this.dynamicModel(k),p-uint32(1),L(p));
        end
        U=randUint32(this.nIU);
        for p=this.iIU
          setInitialUint32(this.dynamicModel(k),p-uint32(1),U(p));
        end
      end
      
      % refresh and extend
      refreshAllMeasures(this);
      extendToCover(this);
      
      % determine initial costs
      bits=getBits(this);
      objectiveContainer('put',this);
      this.cost=feval(@objectiveContainer,bits);
    end
    
    function num=numResults(this)
      num=numel(this.dynamicModel);
    end
       
    function xEst=getTrajectory(this,k)
      xEst=this.dynamicModel(k+1);
    end
    
    function cEst=getCost(this,k)
      cEst=this.cost(k+1);
    end
    
    function step(this)
      refreshAllMeasures(this);
      extendToCover(this);
      bits=getBits(this);
      nvars=size(bits,2);
      nullstate=struct('FunEval',0);
      objectiveContainer('put',this);
      [this.cost,bits]=feval(this.stepGAhandle,this.cost,bits,...
        this.defaultOptions,nullstate,nvars,@objectiveContainer);
      putBits(this,bits);
    end
  end
  
  methods (Access=private)
    function bits=getBits(this)
      K=numel(this.dynamicModel);
      B=numExtensionBlocks(this.dynamicModel(1));
      bits=false(K,this.nIL+this.nIU+B*(this.nEL+this.nEU));
      iB=uint32(1):uint32(B);
      for k=1:K
        Fk=this.dynamicModel(k);
        base=uint32(0);
        for p=this.iIL
          bits(k,base+p)=getInitialLogical(Fk,p-1);
        end
        base=base+this.nIL;
        for p=this.iIU
          bits(k,base+this.iU)=uints2bits(getInitialUint32(Fk,p-1));
          base=base+uint32(32);
        end
        for b=iB
          for p=this.iEL
            bits(k,base+p)=getExtensionLogical(Fk,b-1,p-1);
          end
          base=base+this.nEL;
          for p=this.iEU
            bits(k,base+this.iU)=uints2bits(getExtensionUint32(Fk,b-1,p-1));
            base=base+uint32(32);
          end
        end
      end
    end
    
    function putBits(this,bits)
      K=numel(this.dynamicModel);
      B=numExtensionBlocks(this.dynamicModel(1));
      iB=uint32(1):uint32(B);
      for k=1:K
        Fk=this.dynamicModel(k);
        base=uint32(0);
        for p=this.iIL
          setInitialLogical(Fk,p-1,bits(k,base+p));
        end
        base=base+this.nIL;
        for p=this.iIU
          setInitialUint32(Fk,p-1,bits2uints(bits(k,base+this.iU)));
          base=base+uint32(32);
        end
        for b=iB
          for p=this.iEL
            setExtensionLogical(Fk,b-1,p-1,bits(k,base+p));
          end
          base=base+this.nEL;
          for p=this.iEU
            setExtensionUint32(Fk,b-1,p-1,bits2uints(bits(k,base+this.iU)));
            base=base+uint32(32);
          end
        end
      end
    end
    
    function cost=computeCostMean(this,kBest,naSpan,nbSpan)
      K=numel(this.dynamicModel);
      M=numel(this.measure);
      B=double(numExtensionBlocks(this.dynamicModel(1)));
      allGraphs=cell(K,M+1);

      % build cost graph from prior
      for k=1:K
        Fk=this.dynamicModel(k);
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
        edgeList=findEdges(this.measure{m},this.dynamicModel(kBest),naSpan,nbSpan);
        numEdges(m)=numel(edgeList);
        na=cat(1,edgeList.first);
        nb=cat(1,edgeList.second);
        for k=1:K
          if(numEdges(m))
            cost=zeros(1,numEdges(m));
            for graphEdge=1:numEdges(m)
              cost(graphEdge)=computeEdgeCost(this.measure{m},this.dynamicModel(k),edgeList(graphEdge));
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
    
    function refreshAllMeasures(this)
      for m=1:numel(this.measure)
        refresh(this.measure{m});
      end
    end

    % extends all trajectories to cover the last sensor data
    % should do nothing if there are no measures
    function extendToCover(this)
      tb=WorldTime(-Inf);
      for m=1:numel(this.measure)
        if(hasData(this.measure{m}))
          tb=WorldTime(max(tb,getTime(this.measure{m},last(this.measure{m}))));
        end
      end
      interval=domain(this.dynamicModel(1));
      while(interval.second<tb)
        for k=1:numel(this.dynamicModel)
          Fk=this.dynamicModel(k);
          extend(Fk);
          b=numExtensionBlocks(Fk);
          L=randLogical(this.nEL);
          for p=this.iEL
            setExtensionLogical(Fk,b-uint32(1),p-uint32(1),L(p));
          end
          U=randUint32(this.nEU);
          for p=this.iEU
            setExtensionUint32(Fk,b-uint32(1),p-uint32(1),U(p));
          end
        end
        interval=domain(Fk);
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

function v=randLogical(num)
  v=logical(rand(1,num)>0.5);
end

function v=randUint32(num)
  v=randi([0,4294967295],1,num,'uint32');
end

function varargout=objectiveContainer(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    kBest=find(this.cost==min(this.cost),1,'first');
    putBits(this,bits);
    varargout{1}=computeCostMean(this,kBest,this.nSpan,this.nSpan);
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
