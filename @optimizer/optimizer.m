classdef optimizer
  properties
  end  
  methods (Access=protected)
    function this=optimizer
    end
  end
  methods (Access=public,Abstract=true)
    % Provides initial condition of optimizer input/output
    %
    % INPUT
    % H = objective object
    %
    % OUTPUT
    % v = dynamic seed, M-by-popsize
    % w = static seed, N-by-popsize
    [this,v,w]=init(this,H);

    % Execute one step of the optimizer
    %
    % INPUT/OUTPUT
    % H = objective object
    % v = dynamic seed, M-by-popsize
    % w = static seed, N-by-popsize
    %
    % NOTES
    % The primary purpose of this function is to evolve better seeds {v,w}
    % by implicitly calling the evaluate() function of the objective object.
    %
    % The objective object is passed through eval() but is otherwise 
    % unmodified by step().
    %
    % This function can modify the object state.
    [this,H,v,w]=step(this,H,v,w);
  end
end
