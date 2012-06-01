classdef FeatureExtractor < handle
  methods (Static = true, Access = protected)
    function this = FeatureExtractor()
    end
  end
  
  methods (Abstract = true, Access = public)
    num = numFeatures(this);
    name = getName(this, index);
    feature = getValue(this, index);
  end
end
