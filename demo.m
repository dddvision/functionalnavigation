% This is an example application of the Trajectory Optimization Manager for 
%   Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer
%   and a graphical display, and then alternately optimizes and displays 
%   trajectories in an infinite loop. See DemoConfig for options.
help(mfilename);

% initialize tommas
tommas;

% get configuration
config=DemoConfig;

% instantiate an optimizer
optimizer=Optimizer.factory(config.optimizerName,config.dynamicModelName,config.measureNames,config.uri);

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
