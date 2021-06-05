classdef ThesisDataDDielConfig  < handle
% Copyright 2006 David D. Diel, MIT License
  properties (Constant=true, GetAccess=protected)
    % dataset name ('Factory7', 'GantryB', 'GantryC', or 'GantryF')
    dataSetName = 'GantryB';
  
    % repository URL including ending '/' ('http://people.csail.mit.edu/ddiel/archive/')
    repository = 'http://people.csail.mit.edu/ddiel/archive/';
    
    % seconds per refresh (1)
    secondsPerRefresh = 1;
    
    % display warnings and other diagnostic information (true)
    verbose = true;
  end
end
