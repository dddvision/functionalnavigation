classdef FeatureExtractorComposite < hidi.FeatureExtractor
  properties (GetAccess = private, SetAccess = private)
    lookup = repmat(struct('first', uint32(0), 'second', uint32(0)), 0, 1);
    extractors = cell(0, 1);
  end
  
  methods (Access = public)
    function n =  numFeatures(this)
      n = uint32(numel(this.lookup));
    end

    function name = getFeatureLabel(this, index)
      if(~isa(index, 'uint32'))
        error('FeatureExtractorComposite: Input must be uint32.');
      end
      if(index>=this.numFeatures())
        error('FeatureExtractorComposite: Feature index is out of range.');
      end
      extractorIndex = this.lookup(index+1).first;
      featureIndex = this.lookup(index+1).second;
      name = this.extractors{extractorIndex+1}.getFeatureLabel(featureIndex);
    end

    function value = getFeatureValue(this, index)
      if(~isa(index, 'uint32'))
        error('FeatureExtractorComposite: Input must be uint32.');
      end
      if(index>=this.numFeatures())
        error('FeatureExtractorComposite: Feature index is out of range.');
      end
      extractorIndex = this.lookup(index+1).first;
      featureIndex = this.lookup(index+1).second;
      value = this.extractors{extractorIndex+1}.getFeatureValue(featureIndex);
    end

    function append(this, featureExtractor)
      item = struct('first', uint32(numel(this.extractors)), 'second', uint32(0));
      N = featureExtractor.numFeatures();
      for n = 1:N
        item.second = uint32(n-1);
        this.lookup = [this.lookup; item];
      end
      this.extractors{end+1} = featureExtractor;
    end
  end
end
