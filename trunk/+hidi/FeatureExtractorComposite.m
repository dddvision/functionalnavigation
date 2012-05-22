classdef FeatureExtractorComposite < hidi.FeatureExtractor
  properties (GetAccess = private, SetAccess = private)
    lookup = repmat(struct('first', uint32(0), 'second', uint32(0)), 0, 1);
    extractors = cell(0, 1);
  end
  
  methods (Access = public)
    function n =  numFeatures(this)
      n = uint32(numel(this.lookup));
    end

    function name = getName(this, index)
      assert(isa(index, 'uint32'));
      if(index>=this.numFeatures())
        error('Feature index is out of range.');
      end
      extractorIndex = this.lookup(index+1).first;
      featureIndex = this.lookup(index+1).second;
      name = this.extractors{extractorIndex+1}.getName(featureIndex);
    end

    function value = getValue(this, index)
      assert(isa(index, 'uint32'));
      if(index>=this.numFeatures())
        error('Feature index is out of range.');
      end
      extractorIndex = this.lookup(index+1).first;
      featureIndex = this.lookup(index+1).second;
      value = this.extractors{extractorIndex+1}.getValue(featureIndex);
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
