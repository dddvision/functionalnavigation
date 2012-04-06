classdef SparseTracker < hidi.Sensor
  methods (Access = protected, Static =true)
    % Protected constructor
    %
    % @param[in] initialTime less than or equal to the time stamp of the first data node
    function this = SparseTracker(initialTime)
      this = this@hidi.Sensor(initialTime);
    end
  end
  
  methods (Abstract = true, Access = public)
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
    
    % Find matching features given a pair of nodes
    %
    % @param[in]  nodeA first data index (MATLAB: uint32 scalar)
    % @param[in]  nodeB second data index (MATLAB: uint32 scalar)
    % @param[out] rayA  unit vectors in the first sensor frame (MATLAB: double 3-by-P)
    % @param[out] rayB  unit vectors in the second sensor frame (MATLAB: double 3-by-P)
    %
    % NOTES
    % Throws an exception if either node index is invalid
    [rayA, rayB] = findMatches(this, nodeA, nodeB);
  end
end
