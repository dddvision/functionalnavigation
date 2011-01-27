classdef MatlabGA < MatlabGA.MatlabGAConfig & tom.Optimizer
  
  properties (GetAccess = private, SetAccess = private)
    isDefined
    nSpan
    nIU
    nEU
    iIU
    iEU
    iU
    dynamicModel
    measure
    numSubCosts
    costMean
    defaultOptions
    stepGAhandle
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = ['Applies the MATLAB Genetic Algorithm using a straightforward but slow process. ',...
          'Converts all dynamic model parameters between blocks and bit strings as needed. ',...
          'Optimizes over all parameters at each time step.'];
      end
      tom.Optimizer.connect(name, @componentDescription, @MatlabGA.MatlabGA);
    end
  end
  
  methods (Access = public)
    function this = MatlabGA()
      this = this@tom.Optimizer();
      this.isDefined = false;
    end
    
    function num = numInitialConditions(this)
      num = this.popSize;
    end
      
    function defineProblem(this, dynamicModel, measure, randomize)
      % check number of dynamic models
      assert(numel(dynamicModel)==this.popSize);
      
      % set initial options for the GADS toolbox
      if(~license('test','gads_toolbox'))
        error('Requires license for GADS toolbox -- see MatlabGA configuration options');
      end
      this.defaultOptions = gaoptimset;
      this.defaultOptions.PopulationType = 'bitstring';
      this.defaultOptions.PopInitRange = [0; 1];
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
      this.defaultOptions.EliteCount = 1+floor(this.popSize/12);
      this.defaultOptions.PopulationSize = this.popSize;
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
      userPath = pwd;
      cd(fullfile(fileparts(which('ga')), 'private'));
      temp = @stepGA;
      cd(userPath);
      this.stepGAhandle = temp;
      
      % compute span associated with a maximum number of graph edges (edges<=span*(span+1)/2)
      this.nSpan = uint32(floor(-0.5+sqrt(0.25+2*this.maxEdges)));

      % copy input argument handles
      this.dynamicModel = dynamicModel;
      this.measure = measure;
      
      % get parameter structure
      this.nIU = dynamicModel(1).numInitial();
      this.nEU = dynamicModel(1).numExtension();
      this.iIU = uint32(1):this.nIU;
      this.iEU = uint32(1):this.nEU;
      this.iU = uint32(1):uint32(32);
      
      % randomize initial parameters
      if(randomize)
        for k = 1:this.popSize
          U = randUint32(this.nIU);
          for p = this.iIU
            this.dynamicModel(k).setInitial(p-uint32(1), U(p));
          end
        end
      end
      
      % determine initial costs
      bits = this.getBits();
      objectiveContainer('put', this);
      this.costMean = feval(@objectiveContainer, bits);
      this.isDefined = true;
    end
    
    function refreshProblem(this)
      assert(this.isDefined);
      tb = tom.WorldTime(-Inf);
      [cBest, iBest] = min(this.costMean(:));
      for m = 1:numel(this.measure)
        this.measure{m}.refresh(this.dynamicModel(iBest));
        if(this.measure{m}.hasData())
          tb = tom.WorldTime(max(tb, this.measure{m}.getTime(this.measure{m}.last())));
        end
      end
      K = numel(this.dynamicModel);
      interval = this.dynamicModel(1).domain();
      initialUpperBound = interval.second;
      while(interval.second<tb)
        for k = 1:K
          Fk = this.dynamicModel(k);
          extend(Fk);
          b = Fk.numBlocks();
          U = randUint32(this.nEU);
          for p = this.iEU
            Fk.setExtension(b-uint32(1), p-uint32(1), U(p));
          end
        end
        interval = Fk.domain();
        if(interval.second<=initialUpperBound)
          break;
        end
      end
    end
    
    function num = numSolutions(this)
      num = uint32(numel(this.dynamicModel));
    end
       
    function xEst = getSolution(this, k)
      xEst = this.dynamicModel(k+1);
    end
    
    function cEst = getCost(this, k)
      cEst = this.costMean(k+1)*this.numSubCosts;
    end
    
    function step(this)
      assert(this.isDefined);
      bits = getBits(this);
      if(~isempty(bits))
        nvars = size(bits, 2);
        nullstate = struct('FunEval', 0);
        objectiveContainer('put', this);
        this.costMean(this.costMean<eps) = eps; % MATLAB GA doesn't like zero cost
        [this.costMean, bits] = feval(this.stepGAhandle, this.costMean, bits, ...
          this.defaultOptions, nullstate, nvars, @objectiveContainer);
        this.putBits(bits);
      end
    end
  end
  
  methods (Access = private)
    % Each bit string is packed in the following order:
    %   initial uint32
    %   extension 1 uint32
    %   extension 2 uint32
    %   ...   
    function bits = getBits(this)
      K = numel(this.dynamicModel);
      B = this.dynamicModel(1).numBlocks();
      bits = false(K, this.nIU+B*this.nEU);
      iB = uint32(1):uint32(B);
      for k = 1:K
        Fk = this.dynamicModel(k);
        base = uint32(0);
        for p = this.iIU
          bits(k, base+this.iU) = uints2bits(Fk.getInitial(p-1));
          base = base+uint32(32);
        end
        for b = iB
          for p = this.iEU
            bits(k, base+this.iU) = uints2bits(Fk.getExtension(b-1, p-1));
            base = base+uint32(32);
          end
        end
      end
    end
    
    function putBits(this, bits)
      K = numel(this.dynamicModel);
      B = this.dynamicModel(1).numBlocks();
      iB = uint32(1):uint32(B);
      for k = 1:K
        Fk = this.dynamicModel(k);
        base = uint32(0);
        for p = this.iIU
          Fk.setInitial(p-1, bits2uints(bits(k, base+this.iU)));
          base = base+uint32(32);
        end
        for b = iB
          for p = this.iEU
            Fk.setExtension(b-1, p-1, bits2uints(bits(k, base+this.iU)));
            base = base+uint32(32);
          end
        end
      end
    end
    
    function cost = computeCostMean(this, nSpan)
      K = numel(this.dynamicModel);
      M = numel(this.measure);
      B = double(this.dynamicModel(1).numBlocks());
      allGraphs = cell(K, M+1);

      % build cost graph from prior
      for k = 1:K
        Fk = this.dynamicModel(k);
        cost = zeros(1, B+1);
        cost(1) = Fk.computeInitialCost();
        for b = uint32(1):uint32(B)
          cost(b+1) = Fk.computeExtensionCost(b-1);
        end
        cost = sparse([1, 1:B], 1:(B+1), cost, B+1, B+1, B+1);
        allGraphs{k, 1} = cost;
      end

      % build cost graphs from measures
      numEdges = zeros(1, M);
      for m = 1:M
        gm = this.measure{m};
        if(gm.hasData())
          nMax = gm.last();
          nMin = nMax-nSpan+uint32(1);
          edgeList = gm.findEdges(nMin, nMax, nMin, nMax);
          numEdges(m) = numel(edgeList);
          na = cat(1, edgeList.first);
          nb = cat(1, edgeList.second);
          for k = 1:K
            if(numEdges(m))
              cost = zeros(1, numEdges(m));
              for graphEdge = 1:numEdges(m)
                edgeCost = gm.computeEdgeCost(this.dynamicModel(k), edgeList(graphEdge));
                if(~isnan(edgeCost))
                  cost(graphEdge) = edgeCost;
                end
              end
              base = na(1);
              span = double(nb(end)-base+1);
              allGraphs{k, 1+m} = sparse(double(na-base+1), double(nb-base+1), cost, span, span, numEdges(m));
            else
              allGraphs{k, 1+m} = 0;
            end
          end
        else
          for k = 1:K
            allGraphs{k, 1+m} = 0;
          end
        end
      end

      % sum costs across graphs for each individual
      cost = zeros(K, 1);
      for k = 1:K
        for m = 1:(M+1)
          costkm = allGraphs{k, m};
          cost(k) = cost(k)+sum(costkm(:));
        end
      end

      % normalize costs by total number of blocks and edges
      this.numSubCosts = 1+B+sum(numEdges);
      cost = cost/this.numSubCosts;
    end
  end
  
end

% bits = logical, 1-by-N
function uints = bits2uints(bits)
  bits = reshape(bits, [32, numel(bits)/32]);
  pow = pow2(31:-1:0);
  uints = uint32(sum(pow*bits, 1));
end
 
% uints = uint32 1-by-N
function bits = uints2bits(uints)
  bits = rem(floor(transpose(pow2(-31:0))*double(uints)), 2);
  bits = bits(:);
end

function v = randUint32(num)
  intMax = 4294967295;
  v = randi([0, intMax], 1, num, 'uint32');
end

function varargout = objectiveContainer(varargin)
  persistent this
  bits = varargin{1};
  if(~ischar(bits))
    this.putBits(bits);
    varargout{1} = this.computeCostMean(this.nSpan);
  elseif(strcmp(bits, 'put'))
    this = varargin{2};
  else
    error('incorrect argument list');
  end
end
