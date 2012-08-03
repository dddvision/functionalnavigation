classdef FeatureExtractor < handle
  methods (Static = true, Access = protected)
    function this = FeatureExtractor()
    end
  end
  
  methods (Abstract = true, Access = public)
    num = numFeatures(this);
    name = getFeatureLabel(this, index);
    feature = getFeatureValue(this, index);
  end
end
