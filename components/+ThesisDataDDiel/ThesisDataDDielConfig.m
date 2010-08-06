classdef ThesisDataDDielConfig  < handle
  properties (Constant=true,GetAccess=protected)
    % dataset name: 'Factory7', 'GantryB', 'GantryC', or 'GantryF'
    dataSetName='GantryB';
  
    % repository URL including ending '/'
    repository='http://people.csail.mit.edu/ddiel/archive/';
    
    % display warnings and other diagnostic information (false)
    verbose=false; 
  end
end
