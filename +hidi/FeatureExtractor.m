classdef FeatureExtractor < handle
  methods (Access = protected, Static = true)
    function this = FeatureExtractor()
    end
  end
  
  methods (Access = public, Abstract = true)
    num = numFeatures(this);
    name = getFeatureLabel(this, index);
    feature = getFeatureValue(this, index);
  end
end
