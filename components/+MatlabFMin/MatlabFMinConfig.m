classdef MatlabFMinConfig < handle
  properties (Constant = true, GetAccess = protected)
    maxEdges = 10000; % (10000) maximum number of edges to compute for each measure
    maxParameters = 36; % (36) maximum number of parameters to include in optimization
    verbose = false; % (true) enable verbose errors and warnings
  end
end
