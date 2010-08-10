% This is an example application of the Trajectory Optimization Manager for 
%   Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer
%   and a graphical display, and then alternately optimizes and displays 
%   trajectories in an infinite loop. See DemoConfig for options.
help(mfilename);

% initialize tommas
tommas;

% get configuration
config=DemoConfig;

% initialize multiple measures
M=numel(config.measureNames);
measure=cell(M,1);
for m=1:M
  measure{m}=Measure.factory(config.measureNames{m},config.uri);
end

% determine initial time based on first available data node
initialTime=WorldTime(Inf);
for m=1:M
  refresh(measure{m});
  if(hasData(measure{m}))
    initialTime=WorldTime(min(initialTime,getTime(measure{m},first(measure{m}))));
  end
end

% use default initial time when no data is available
if(isinf(initialTime))
  initialTime=config.defaultInitialTime;
end
  
% initialize multiple dynamic models
dynamicModel=DynamicModel.factory(config.dynamicModelName,initialTime,config.uri);
for k=2:config.numTrajectories
  dynamicModel(k)=DynamicModel.factory(config.dynamicModelName,initialTime,config.uri);
end

% instantiate an optimizer
optimizer=Optimizer.factory(config.optimizerName,dynamicModel,measure);

% instantiate the graphical display
gui=DemoDisplay(config.uri);

% optimize for a number of steps
for index=uint32(0):config.numSteps
  % check number of results
  K=numResults(optimizer);
  
  % if there are any results
  if(K>uint32(0))
    % get all trajectory and cost estimates
    trajectory=getTrajectory(optimizer,uint32(0));
    cost=getCost(optimizer,uint32(0));
    for k=uint32(1):(K-uint32(1))
      trajectory(k,1)=getTrajectory(optimizer,k);
      cost(k,1)=getCost(optimizer,k);
    end
    
    % update graphical display
    put(gui,trajectory,cost,index);
  end
    
  % take an optimization step
  step(optimizer);
end
