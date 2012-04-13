classdef FeatureExtractor < handle
  methods (Abstract = true, Access = public)
    % Get number of elements that will be returned by the extract function.
    %
    % @return number of elements 
    num = numElements(this);
    
    % Get the name for each element.
    %
    % @param[in] index element index
    % return element name
    name = getName(this, index);
    
    % Extract features from sensor data
    %
    % @param[in] sensor    multi-sensor object
    % @param[in] partition list of heel strike indices in ascending order
    % @return              computed feature vector
    feature = extract(this, sensor, partition);
  end
end
