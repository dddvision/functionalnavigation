classdef FeatureExtractorBridge < hidi.FeatureExtractor
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    args % constructor arguments
  end
  
  methods (Access = public, Static = true)
    function this = FeatureExtractorBridge(name, varargin)
      if(nargin>0)
        this.m = hidi.mexPackage(name);
        this.args = varargin;
        feval(this.m, this.args, 'FeatureExtractorCreate');
      end
    end
  end
    
  methods (Access = public) 
    function num = numFeatures(this)
      num = feval(this.m, this.args, 'numFeatures');
    end
    
    function name = getFeatureLabel(this, index)
      name = feval(this.m, this.args, 'getFeatureLabel', index);
    end
    
    function feature = getFeatureValue(this, index)
      feature = feval(this.m, this.args, 'getFeatureValue', index);
    end
  end
end
