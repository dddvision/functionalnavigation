classdef OptimizerDefault < tom.Optimizer
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default optimizer does nothing and provides no solutions.';
      end
      tom.Optimizer.connect(name, @componentDescription, @tom.OptimizerDefault);
    end
  end
 
  methods (Access = public, Static = true)
    function this = OptimizerDefault()
      this = this@tom.Optimizer();
    end
  end
  
  methods (Access = public)  
    function num = numInitialConditions(this)
      assert(isa(this, 'tom.Optimizer'));
      num = uint32(0);
    end
    
    function defineProblem(this, dynamicModel, measure, randomize)
      assert(isa(this, 'tom.Optimizer'));
      assert(isa(dynamicModel, 'tom.DynamicModel'));
      assert(isa(measure, 'cell'));
      assert(isa(randomize, 'logical'));
    end
    
    function refreshProblem(this)
      assert(isa(this, 'tom.Optimizer'));
    end
    
    function num = numSolutions(this)
      assert(isa(this, 'tom.Optimizer'));
      num = uint32(0);
    end
    
    function x = getSolution(this, k)
      assert(isa(this, 'tom.Optimizer'));
      assert(isa(k, 'uint32'));
      x = tom.DynamicModelDefault(tom.WorldTime(0) ,'');
      assert(isa(x, 'tom.Trajectory'));
      error('The default optimizer provides no solutions.');
    end

    function cost = getCost(this, k)
      assert(isa(this, 'tom.Optimizer'));
      assert(isa(k, 'uint32'));
      cost = 0.0;
      assert(isa(cost, 'double'));
      error('The default optimizer provides no solutions.');
    end
    
    function step(this)
      assert(isa(this, 'tom.Optimizer'));
    end
  end
  
end
