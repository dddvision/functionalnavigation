classdef optimizer
  methods (Access=protected)
    function this=optimizer
    end
  end
  methods (Access=public,Abstract=true)
    
    % Execute one step of the optimizer to evolve seeds toward lower cost
    %
    % INPUT/OUTPUT
    % fun = vectorized objective function handle
    % bits = bitstrings in the domain of the objective, popsize-by-nvars
    % cost = cost associated with output bits, popsize-by-1
    %
    % NOTES
    % The optimizer may learn about the objective function over multiple
    % calls by maintaining state using properties.
    % Do not use persistent variables.
    % This function may evaluate the objective multiple times, though a
    % single evaluation per step is preferred.
    [this,bits,cost]=step(this,fun,bits);
    
  end
end
