classdef trajectory
  methods (Abstract)
    [a,b]=domain(this);
    posquat=evaluate(this,t);
  end
end
