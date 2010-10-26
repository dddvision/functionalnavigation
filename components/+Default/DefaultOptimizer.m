classdef DefaultOptimizer < tom.Optimizer
  
  properties (Constant = true, GetAccess = private)
    popSize = uint32(3);
    cost = 0;
  end
  
  properties (GetAccess = private, SetAccess = private)
    isDefined
    dynamicModel
    measure
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default optimizer does not compute or minimize cost.';
      end
      tom.Optimizer.connect(name, @componentDescription, @Default.DefaultOptimizer);
    end
  end
 
  methods (Access = public, Static = true)
    function this = DefaultOptimizer()
      this = this@tom.Optimizer();
      this.isDefined = false;
    end
  end
  
  methods (Access = public, Static = false)  
    function num = numInitialConditions(this)
      num = this.popSize;
    end
    
    function defineProblem(this, dynamicModel, measure, randomize)
      assert(numel(dynamicModel)==this.popSize);
      
      this.dynamicModel = dynamicModel;
      this.measure = measure;
      
      if(randomize)
        nIL = this.dynamicModel(1).numInitialLogical(); 
        nIU = this.dynamicModel(1).numInitialUint32();
        nEL = this.dynamicModel(1).numExtensionLogical();
        nEU = this.dynamicModel(1).numExtensionUint32();
        nEB = this.dynamicModel(1).numExtensionBlocks();
        for k = 1:numel(this.dynamicModel)
          x = this.dynamicModel(k);
          vIL = rand(1, nIL)>=0.5;
          vIU = randi([uint32(0), intmax('uint32')], 1, nIU, 'uint32');
          vEL = rand(nEB, nEL)>=0.5;
          vEU = randi([uint32(0), intmax('uint32')], nEB, nIU, 'uint32');
          for p = uint32(1):nIL
            x.setInitialLogical(p-1, vIL(p));
          end
          for p = uint32(1):nIU
            x.setInitialUint32(p-1, vIU(p));
          end
          for b = uint32(1):nEB
            for p = uint32(1):nEL
              x.setExtensionLogical(b-1, p-1, vEL(b, p));
            end
            for p = uint32(1):nEU
              x.setExtensionUint32(b-1, p-1, vEU(b, p));
            end
          end
        end
      end
      
      this.isDefined = true;
    end
    
    function refreshProblem(this)
      assert(this.isDefined);
      currentTime = tom.WorldTime(-Inf);
      [cBest, iBest] = min(this.cost);
      for m = 1:numel(this.measure)
        this.measure{m}.refresh(this.dynamicModel(iBest));
        if(this.measure{m}.hasData())
          currentTime = tom.WorldTime(max(currentTime, this.measure{m}.getTime(this.measure{m}.last())));
        end
      end
      interval = this.dynamicModel(1).domain();
      while(interval.second<currentTime)
        for k = 1:numel(this.dynamicModel)
          this.dynamicModel(k).extend();
        end
        interval = this.dynamicModel(1).domain();
      end
    end
    
    function num = numSolutions(this)
      num = uint32(numel(this.dynamicModel));
    end
    
    function x = getSolution(this, k)
      x = this.dynamicModel(k+1);
    end

    function cost = getCost(this, k)
      assert(isa(k, 'uint32'));
      cost = this.cost;
    end
    
    function step(this)
      assert(isa(this, 'tom.Optimizer'));
    end
  end
  
end
