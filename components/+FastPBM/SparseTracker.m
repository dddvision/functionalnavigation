classdef SparseTracker < tom.Sensor
  
  methods (Abstract=true,Access=public,Static=false)
    % Refresh the tracker given a predicted body trajectory
    %
    % @param[in] x predicted body trajectory
    %
    % NOTES
    % If the predicted body trajectory is not available then use the sensor refresh function without arguments
    % @see tom.Sensor.refresh()
    refreshWithPrediction(this, x);
    
    % Check whether the sensor frame moves relative to the body framer
    %
    % @param[out] flag true if the offset can change or false otherwise (MATLAB: bool scalar)
    flag = isFrameDynamic(this);
    
    % Get sensor frame position and orientation relative to the body frame
    %
    % @param[in]  node data index (MATALB: uint32 scalar)
    % @param[out] pose position and orientation of sensor origin in the body frame (MATLAB: Pose scalar)
    %
    % NOTES
    % Sensor frame axis order is forward-right-down relative to the body frame
    % Throws an exception when the data index is invalid
    pose = getFrame(this, node);
    
    % Number of features associated with a data node
    %
    % @param[in] node data index (MATLAB: uint32 scalar)
    % @return         number of features associated with the data index (MATLAB: uint32 M-by-1)
    %
    % NOTES
    % Throws an exception when the data index is invalid
    num = numFeatures(this, node);
    
    % Get unique identifier of a feature
    %
    % @param[in] node       data index (MATLAB: uint32 scalar)
    % @param[in] localIndex zero-based feature indices relative to the specified node (MATLAB: uint32 1-by-P)
    % @return               unique feature identifiers (MATLAB: uint32 1-by-P)
    %
    % NOTES
    % Throws an exception when the data index is invalid
    id = getFeatureID(this, node, localIndex);
    
    % Get ray vector corresponding to the direction of a feature relative to the sensor frame
    %
    % @param[in] node       data index (MATLAB: uint32 scalar)
    % @param[in] localIndex zero-based feature indices relative to the specified node (MATLAB: uint32 1-by-P)
    % @return               unit vector in the sensor frame (MATLAB: double 3-by-P)
    %
    % NOTES
    % Throws an exception if either the node or the feature index are invalid
    % @see getFeatures()
    ray = getFeatureRay(this, node, localIndex);
  end

end
