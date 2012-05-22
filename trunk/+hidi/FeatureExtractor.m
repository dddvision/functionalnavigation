classdef FeatureExtractor < handle
  methods (Abstract = true, Access = public)
    num = numFeatures(this);
    name = getName(this, index);
    feature = getValue(this, index);
  end
end
