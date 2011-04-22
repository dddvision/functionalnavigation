classdef MatlabFMinConfig < handle
  properties (Constant = true, GetAccess = protected)
    maxEdges = 10000; % (10000) maximum number of edges to compute for each measure
    maxParameters = 1000; % (1000) maximum number of parameters to include in optimization
    verbose = true; % (true) enable verbose errors and warnings
  end
end
