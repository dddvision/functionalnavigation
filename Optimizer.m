% This class defines the interface to an optimization engine
classdef Optimizer < handle

  methods (Access=protected,Static=true)
    % Protected method to construct a component
    %
    % INPUT
    % dynamicModel = multiple instances of a single DynamicModel subclass, DynamicModel K-by-1
    % measure = multiple instances of different Measure subclasses, cell M-by-1
    %
    % NOTES
    % No assumptions should be made about the initial state of the input objects
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@Optimizer(dynamicModel,measure);
    function this=Optimizer(dynamicModel,measure)
      assert(isa(dynamicModel,'DynamicModel'));
      assert(isa(measure,'cell'));
      for m=1:numel(measure)
        assert(isa(measure{m},'Measure'));
      end
    end
    
    % Establish connection between framework class and component
    %
    % INPUT
    % name = component identifier, string
    % cD = function that returns a user friendly description, function handle
    % cF = function that can instantiate the subclass, function handle
    %
    % NOTES
    % The description may be truncated after a few hundred characters when displayed
    % The description should not contain line feed or return characters
    % A component can connect to multiple framework classes
    % (C++) Call this function prior to the invocation of main() using an initializer class
    % (MATLAB) Call this function from initialize()
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         pDescriptionList(name,cD);
         pFactoryList(name,cF);
      end
    end
  end
      
  methods (Access=public,Static=true)
    % Check if a named subclass is connected with this base class
    %
    % INPUT
    % name = component identifier, string
    %
    % OUTPUT
    % flag = true if the subclass exists and is connected to this base class, logical scalar
    %
    % NOTES
    % Do not shadow this function
    % A package directory identifying the component must in the environment path
    % Omit the '+' prefix when identifying package names
    function flag=isConnected(name)
      flag=false;
      if(exist([name,'.',name],'class'))
        try
          feval([name,'.',name,'.initialize'],name);
        catch err
          err.message;
        end  
        if(isfield(pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    % Get user friendly description of a component
    %
    % INPUT
    % name = component identifier, string
    %
    % OUTPUT
    % text = user friendly description, string
    %
    % NOTES
    % Do not shadow this function
    % If the component is not connected then the output is an empty string
    function text=description(name)
      text='';
      if(Optimizer.isConnected(name))
        dL=pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    % Public method to construct a component
    %
    % INPUT
    % name = component identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, Optimizer scalar
    %
    % NOTES
    % Do not shadow this function
    % Throws an error if the component is not connected
    function obj=factory(name,dynamicModel,measure)
      if(Optimizer.isConnected(name))
        cF=pFactoryList(name);
        obj=cF.(name)(dynamicModel,measure);
        assert(isa(obj,'Optimizer'));
      else
        error('Optimizer is not connected to the requested component');
      end
    end
  end
  
  methods (Abstract=true,Access=protected,Static=true)
    % (MATLAB) Initializes connections between a component and one or more framework classes
    %
    % INPUT
    % name = component identifier, string
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    % Get the number of results
    %
    % OUTPUT
    % num = number of results, uint32 scalar
    num=numResults(this);
    
    % Get the most recent trajectory estimate in the form of a dynamic model
    %
    % INPUT
    % k = zero based result index, uint32 scalar
    %
    % OUTPUT
    % xEst = trajectory instance in the form of a dynamic model, DynamicModel scalar
    %
    % NOTES
    % This function returns initial conditions if called before the first optimization step occurrs
    % Throws an exception if index is out of range
    xEst=getTrajectory(this,k);
    
    % Get the most recent cost estimate
    %
    % INPUT
    % k = zero based result index, uint32 scalar
    %
    % OUTPUT
    % cEst = non-negative cost associated with each trajectory instance, double scalar
    %
    % NOTES
    % This function returns initial conditions if called before the first optimization step occurrs
    % Throws an exception if index is out of range
    cEst=getCost(this,k);
    
    % Execute one step of the optimizer to evolve parameters toward lower cost
    %
    % NOTES
    % This function refreshes the objective and determines the current 
    %   number of input parameter blocks and output costs
    % The optimizer may learn about the objective function over multiple
    %   calls by maintaining state using class properties
    % This function may evaluate the objective multiple times, though a
    %   single evaluation per step is preferred
    step(this);
  end
  
end

% Storage for component descriptions
function dL=pDescriptionList(name,cD)
  persistent descriptionList
  if(nargin==2)
    descriptionList.(name)=cD;
  else
    dL=descriptionList;
  end
end

% Storage for component factories
function fL=pFactoryList(name,cF)
  persistent factoryList
  if(nargin==2)
    factoryList.(name)=cF;
  else
    fL=factoryList;
  end
end
