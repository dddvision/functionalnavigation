% Inherits the Sensor interface as follows:
% refresh(this);
% flag=hasData(this);
% n=first(this);
% n=last(this);
% time=getTime(this,n);
classdef SparseTracker < Sensor

  properties (Constant=true,GetAccess=public)
    maxFeatures = 30; % (30) maximum integer number of features per frame to find
    maxFrames = 10; % (10) maximum integer number of frames to track a feature
    maxSearch = 0.05; % (0.05) approximate maximum angle to search for a feature in radians
  end

  methods (Access=public,Static=true)
    % Constructor
    %
    % @param[in] camera camera object
    % @return           instance of this class
    function this=SparseTracker(camera)
      assert(isa(camera,'Camera'));
    end
  end
  
  methods (Abstract=true,Access=public,Static=false)
    % Refresh the tracker given a predicted body trajectory
    %
    % @param[in] x predicted body trajectory
    %
    % NOTES
    % If the predicted body trajectory is not available then use the sensor refresh function without arguments
    % @see tom.Sensor.refresh()
    refreshWithPrediction(this, x);
    
    % Get a list of features associated with an image
    %
    % @param[in] node unique image index (MATLAB: uint32 scalar)
    % @return         list of unique feature indices (MATLAB: uint32 M-by-1)
    featureList = getFeatures(this, node);
    
    % Get a list of images associated with a feature
    %
    % @param[in] feature unique feature index (MATLAB: uint32 scalar)
    % @return            list of image indices (MATLAB: uint32 N-by-1)
    %
    % NOTES
    % Throws an exception if feature index is not valid 
    % @see getFeatures()
    nodeList = getCorrespondence(this, feature);
    
    % Get ray vector corresponding to the position of a feature in an image
    %
    % @param[in] node    unique image index (MATLAB: uint32 scalar)
    % @param[in] feature unique feature index (MATLAB: uint32 scalar)    
    % @return            unit vector in camera frame (MATLAB: double 3-by-1)
    %
    % NOTES
    % Throws an exception if either the node or the feature index are not valid
    % @see getFeatures()
    % @see getCorrespondence()
    ray = getFeatureRay(this, node, feature);
  end

end
