classdef FeatureExtractorBridge < hidi.FeatureExtractor
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    args % constructor arguments
  end
  
  methods (Access = public, Static = true)
    function this = FeatureExtractorBridge(name, varargin)
      if(nargin>0)
        this.m = compileOnDemand(name);
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

% Attempt once to compile on demand.
function mName = compileOnDemand(name)
  persistent mNameCache
  if(isempty(mNameCache))
    mNameCache = [name, '.', name(find(['.', name]=='.', 1, 'last'):end), 'Bridge'];
    bridge = mfilename('fullpath');
    arg{1} = ['-I"', fileparts(fileparts(bridge)), '"'];
    arg{2} = '-output';
    cpp = which([fullfile(['+', name], name), '.cpp']);
    arg{3} = ['''', cpp(1:(end-4)), 'Bridge'''];
    arg{4} = ['''', bridge, '.cpp'''];
    if(exist(arg{3}, 'file'))
      delete([arg{3}, '.', mexext]);
    end
    cmd = ['mex' sprintf(' %s', arg{:})];
    fprintf('\n%s\n', cmd);
    eval(cmd);
  end
  mName = mNameCache;
end
