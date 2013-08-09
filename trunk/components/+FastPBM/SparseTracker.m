classdef SparseTracker < hidi.Sensor
  methods (Access = protected, Static =true)
    % Protected constructor
    %
    % @param[in] initialTime less than or equal to the time stamp of the first data node
    function this = SparseTracker(initialTime)
      this = this@hidi.Sensor();
      assert(isa(initialTime, 'double'));
    end
  end
  
  methods (Abstract = true, Access = public)
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
