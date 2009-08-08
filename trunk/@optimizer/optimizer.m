classdef optimizer
  methods (Abstract)
    [this,v,w]=init(this,H);
    [this,H,v,w]=step(this,H,v,w);
  end
end
