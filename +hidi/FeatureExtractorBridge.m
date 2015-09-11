classdef FeatureExtractorBridge < hidi.FeatureExtractor
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    args % constructor arguments
  end
  
  methods (Access = public, Static = true)
    function mName = compile(name, varargin)
      persistent mNameMap
      if(isempty(mNameMap))
        mNameMap = containers.Map;
      end
      if(~isKey(mNameMap, name))
        mNameMap(name) = [name, '.', name(find(['.', name]=='.', 1, 'last'):end), 'Bridge'];
        bridge = mfilename('fullpath');
        arg{1} = ['-I"', fileparts(fileparts(bridge)), '"'];
        arg{2} = [bridge, '.cpp'];
        arg{3} = '-output';
        cpp = which([fullfile(['+', name], name), '.cpp']);
        arg{4} = [cpp(1:(end-4)), 'Bridge'];
        if(exist(arg{4}, 'file'))
          delete([arg{4}, '.', mexext]);
        end
        arg = cat(2, arg, varargin);
        fprintf('mex');
        fprintf(' %s', arg{:});
        hidi.newline();
        mex(arg{:});
      end
      mName = mNameMap(name);
    end
    
    function this = FeatureExtractorBridge(name, varargin)
      if(nargin>0)
        this.m = hidi.FeatureExtractorBridge.compile(name, varargin{:});
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
