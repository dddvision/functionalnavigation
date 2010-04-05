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
    objective
    cost
    defaultOptions
    stepGAhandle
  end
  
  methods (Access=public)
    function this=MatlabGA(objective)
      this=this@Optimizer(objective);
            
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
      
      % add inputs to the objective
      for k=numel(objective.input):this.PopulationSize
        addInput(objective);
      end
      
      % determine initial costs
      bits=getBits(objective);
      objectiveContainer('put',objective);
      this.objective=objective;
      this.cost=feval(@objectiveContainer,bits);
    end
    
    function [xEst,cEst]=getResults(this)
      xEst=this.objective.input;
      cEst=this.cost;
    end
    
    function step(this)
      refresh(this.objective);
      bits=getBits(this.objective);
      nvars=size(bits,2);
      nullstate=struct('FunEval',0);
      objectiveContainer('put',this.objective);
      [this.cost,bits]=feval(this.stepGAhandle,this.cost,bits,...
        this.defaultOptions,nullstate,nvars,@objectiveContainer);
      putBits(this.objective,bits);
    end
  end
end

function [n1,n2,n3,n4]=analyzeStructure(objective)
  n1=objective.input.initialBlockDescription.numLogical;
  n2=n1+32*objective.input.initialBlockDescription.numUint32;
  n3=objective.input.extensionBlockDescription.numLogical;
  n4=n3+32*objective.input.extensionBlockDescription.numUint32;
end

function bits=getBits(objective)
  [n1,n2,n3,n4]=analyzeStructure(objective);
  K=numel(objective.input);
  B=objective.input(1).numExtensionBlocks;
  bits=false(K,n2+B*n4);
  for k=1:K
    initialBlock=getInitialBlock(objective.input(k));
    bits(k,1:n1)=initialBlock.logical;
    bits(k,(n1+1):n2)=uints2bits(initialBlock.uint32);
    base=n2;
    for b=1:B
      extensionBlock=getExtensionBlocks(objective.input(k),uint32(b-1));
      bits(k,(base+uint32(1)):(base+n3))=extensionBlock.logical;
      bits(k,(base+n3+uint32(1)):(base+n4))=uints2bits(extensionBlock.uint32);
      base=base+n4;
    end
  end
end

function putBits(objective,bits)
  [n1,n2,n3,n4]=analyzeStructure(objective);
  for k=1:numel(objective.input)
    b=bits(k,:);
    initialBlock=struct('logical',b(1:n1),'uint32',bits2uints(b((n1+1):n2)));
    extensionBlocks=struct('logical',{},'uint32',{});
    numLeftover=size(b,2)-n2;
    numEBits=n3+n4;
    base=n2;
    if(numEBits)
      for blk=1:(numLeftover/numEBits)
        extensionBlocks(blk)=struct('logical',b((base+uint32(1)):(base+n3)),...
          'uint32',bits2uints(b((base+n3+uint32(1)):(base+n4))));
        base=base+n4;
      end
    end
    setInitialBlock(objective.input(k),initialBlock);
    if(~isempty(extensionBlocks))
      setExtensionBlocks(objective.input(k),...
        uint32(0:(numel(extensionBlocks)-1)),extensionBlocks);
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

function varargout=objectiveContainer(varargin)
  persistent this
  bits=varargin{1};
  if(~ischar(bits))
    putBits(this,bits);
    varargout{1}=computeCostMean(this);
  elseif(strcmp(bits,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
