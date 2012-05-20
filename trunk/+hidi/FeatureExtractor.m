classdef FeatureExtractor < handle

  methods (Static = true, Access = public)
    % Extract and concatenate all features.
    %
    % @param[in] package       sensor package
    % @param[in] extractorList list of instantiated feature extractor objects
    function features = cat(extractorList)
      numExtractors = numel(extractorList);
      numFeatures = zeros(numExtractors, 1);
      for index = 1:numExtractors
        numFeatures(index) = extractorList{index}.numFeatures();
      end
      features = zeros(sum(numFeatures), 1);
      offset = 1;
      for index = 1:numExtractors
        for n = uint32(0):(numFeatures(index)-1);
          features(offset) = extractorList{index}.getValue(n);
          offset = offset+1;
        end
      end
    end
  end
  
  methods (Abstract = true, Access = public)
    % Get number of features available from the extract function.
    %
    % @return number of features
    num = numFeatures(this);
    
    % Get the name of a feature.
    %
    % @param[in] index feature index
    % return           feature name
    name = getName(this, index);
    
    % Extract features from sensor data.
    %
    % @param[in] index feature index
    % return           feature value
    feature = getValue(this, index);
  end
end
