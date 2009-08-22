classdef optimizer
  properties
  end  
  methods (Access=protected)
    function this=optimizer
    end
  end
  methods (Access=public,Abstract=true)
    % Execute one step of the optimizer
    %
    % INPUT/OUTPUT
    % v = trajectory seed, M-by-popsize
    % w = sensor seed, N-by-popsize
    % c = cost, 1-by-popsize
    %
    % NOTES
    % The primary purpose of this function is to evolve better seeds {v,w}
    % by implicitly calling the evaluate() function of the objective object.
    %
    % The objective object is passed through eval() but is otherwise 
    % unmodified by step().
    %
    % This function can modify the object state.
    [this,v,w]=step(this,v,w,c);
  end
end
