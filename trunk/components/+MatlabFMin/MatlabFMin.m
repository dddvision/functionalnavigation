classdef MatlabFMin < MatlabFMin.MatlabFMinConfig & tom.Optimizer
  
  properties (Constant = true, GetAccess = private)
    popSize = uint32(1);
    intMax = 4294967295;
  end
    
  properties (GetAccess = private, SetAccess = private)
    isDefined
    nSpan
    nIU
    nEU
    iIU
    iEU
    dynamicModel
    options
    measure
    costMean
    numSubCosts
    maxExtensionBlocks
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'Applies MATLAB interior-point algorithm for constrained function minimization.';
      end
      tom.Optimizer.connect(name, @componentDescription, @MatlabFMin.MatlabFMin);
    end
  end
  
  methods (Access = public)
    function this = MatlabFMin()
      this = this@tom.Optimizer();
      this.isDefined = false;
    end
    
    function num = numInitialConditions(this)
      num = this.popSize;
    end
      
    function defineProblem(this, dynamicModel, measure, randomize)
      % check number of dynamic models
      assert(numel(dynamicModel)==this.popSize);
      
      % set initial options for the optimization toolbox
      if(~license('test', 'optimization_toolbox'))
        error('Requires license for MATLAB optimization toolbox -- see MatlabFMin configuration options');
      end
      this.options = optimset;
      this.options.Algorithm = 'interior-point';
      this.options.LargeScale = 'on';
      this.options.TolFun = 0;
      this.options.TolX = 0;
      this.options.TolCon = 0;
      this.options.MaxIter = 2;
      if(~this.verbose)
        this.options.Display = 'off';
      end

      % compute span associated with a maximum number of graph edges (edges<=span*(span+1)/2)
      this.nSpan = uint32(floor(-0.5+sqrt(0.25+2*this.maxEdges)));

      % copy input argument handles
      this.dynamicModel = dynamicModel;
      this.measure = measure;
      
      % get parameter structure
      this.nIU = dynamicModel.numInitial();
      this.nEU = dynamicModel.numExtension();
      this.iIU = (uint32(1):this.nIU)-uint32(1);
      this.iEU = (uint32(1):this.nEU)-uint32(1);
      this.maxExtensionBlocks = (this.maxParameters-this.nIU)/this.nEU; % integer math
      P = this.getParameters();
      
      % randomize parameters
      if(randomize)
        P = randUint32(numel(P));
      end
      
      % determine initial costs
      objectiveContainer('put', this);
      P = double(P)/this.intMax;
      this.costMean = feval(@objectiveContainer, P); % sets parameters
      this.isDefined = true;
    end
    
    function refreshProblem(this)
      assert(this.isDefined);
      tb = tom.WorldTime(-Inf);
      for m = 1:numel(this.measure)
        this.measure{m}.refresh(this.dynamicModel);
        if(this.measure{m}.hasData())
          tb = tom.WorldTime(max(tb, this.measure{m}.getTime(this.measure{m}.last())));
        end
      end
      interval = this.dynamicModel.domain();
      initialUpperBound = interval.second;
      while(interval.second<tb)
        F = this.dynamicModel;
        extend(F);
        B = F.numBlocks();
        U = randUint32(this.nEU);
        for p = this.iEU
          F.setExtension(B-uint32(1), p, U(p+1));
        end
        interval = F.domain();
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
      P = getParameters(this);
      N = numel(P);
      if(N>0)
        this.options.MaxFunEvals = 1+floor(N*log(N));
        objectiveContainer('put', this);
        lb = zeros(N, 1);
        ub = ones(N, 1);
        P = double(P)/this.intMax;
        [P, this.costMean] = fmincon(@objectiveContainer, P, [], [], [], [], lb, ub, [], this.options);
        P = uint32(round(P*this.intMax));
        this.putParameters(P);
      end
      if(this.verbose)
        fprintf('\nparameters = ');
        fprintf('%u ', P);
      end
    end
  end
  
  methods (Access = private)
    function P = getParameters(this)
      B = this.dynamicModel.numBlocks();
      iB = ((B-this.maxExtensionBlocks+uint32(1)):B)-uint32(1); % integer math
      P = zeros(this.nIU+numel(iB)*this.nEU, 1, 'uint32');
      F = this.dynamicModel;
      pp = 1;
      for p = this.iIU
        P(pp) = F.getInitial(p);
        pp = pp+1;
      end
      for b = iB
        for p = this.iEU
          P(pp) = F.getExtension(b, p);
          pp = pp+1;
        end
      end
    end
    
    function putParameters(this, P)
      B = this.dynamicModel.numBlocks();
      iB = ((B-this.maxExtensionBlocks+uint32(1)):B)-uint32(1); % integer math
      F = this.dynamicModel;
      pp = 1;
      for p = this.iIU
        F.setInitial(p, P(pp));
        pp = pp+1;
      end
      for b = iB
        for p = this.iEU
          F.setExtension(b, p, P(pp));
          pp = pp+1;
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
      this.numSubCosts = 1+B+sum(numEdges); % includes one initial condition
      cost = cost/this.numSubCosts;
    
      if(this.verbose)
        fprintf('\ncostMean = %f', cost);
      end
    end
  end
  
end

function v = randUint32(N)
  intMax = 4294967295;
  v = randi([0, intMax], N, 1, 'uint32');
end

% input parameters are expected to be doubles in the range [0, 1]
function varargout = objectiveContainer(varargin)
  persistent this
  P = varargin{1};
  if(~ischar(P))
    P = uint32(round(P*this.intMax));
    this.putParameters(P);
    varargout{1} = this.computeCostMean(this.nSpan);
  elseif(strcmp(P, 'put'))
    this = varargin{2};
  else
    error('incorrect argument list');
  end
end
