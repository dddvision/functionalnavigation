classdef FeatureExtractor < handle

  methods (Static = true, Access = public)
    function this = FeatureExtractor(samplingFrequency)
      assert(numel(samplingFrequency)==1);
    end
    
    % Extract and concatenate all features.
    %
    % @param[in] package       sensor package
    % @param[in] partition     vector of data partitions
    % @param[in] extractorList list of instantiated feature extractor objects
    function features = cat(package, partition, extractorList)
      numExtractors = numel(extractorList);
      numFeatures = zeros(numExtractors, 1);
      for index = 1:numExtractors
        numFeatures(index) = extractorList{index}.numFeatures();
      end
      features = zeros(sum(numFeatures), 1);
      offset = 0;
      for index = 1:numExtractors
        N = numFeatures(index);
        features(offset+(1:N)) = extractorList{index}.getValue(package, partition);
        offset = offset+N;
      end
    end
  end
  
  methods (Abstract = true, Access = public)
    % Get number of features available from the extract function.
    %
    % @return number of features
    num = numFeaturesthis(this);
    
    % Get the name of a feature.
    %
    % @param[in] index feature index
    % return           feature name
    name = getName(this, index);
    
    % Extract features from sensor data.
    %
    % @param[in] sensor    multi-sensor object
    % @param[in] partition list of heel strike indices in ascending order
    % @return              computed feature vector
    feature = getValue(this, sensor, partition);
  end
end
