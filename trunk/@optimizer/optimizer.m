classdef optimizer
  methods (Access=protected)
    function this=optimizer
    end
  end
  methods (Access=public,Abstract=true)
    
    % Execute one step of the optimizer to evolve seeds toward lower cost
    %
    % INPUT/OUTPUT
    % v = trajectory seed, M-by-popsize
    % w = sensor seed, N-by-popsize
    % c = cost, 1-by-popsize
    [this,v,w]=step(this,v,w,c);
    
  end
end
