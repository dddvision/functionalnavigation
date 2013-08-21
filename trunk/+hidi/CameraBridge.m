classdef CameraBridge < hidi.Camera
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = CameraBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'cameraRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'cameraHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'cameraFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'cameraLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'cameraGetTime', n);
    end
    
    function str = interpretLayers(this)
      str = feval(this.m, this.h, 'interpretLayers');
    end
    
    function num = numStrides(this)
      num = feval(this.m, this.h, 'numStrides');
    end
    
    function num = numSteps(this)
      num = feval(this.m, this.h, 'numSteps');
    end
    
    function stride = strideMin(this, node)
      stride = feval(this.m, this.h, 'strideMin', node);
    end
    
    function stride = strideMax(this, node)
      stride = feval(this.m, this.h, 'strideMax', node);
    end
    
    function step = stepMin(this, node)
      step = feval(this.m, this.h, 'stepMin', node);
    end
    
    function step = stepMax(this, node)
      step = feval(this.m, this.h, 'stepMax', node);
    end
    
    function [stride, step] = projection(this, forward, right, down)
      [stride, step] = feval(this.m, this.h, 'projection', forward, right, down);
    end
    
    function [forward, right, down] = inverseProjection(this, stride, step)
      [forward, right, down] = feval(this.m, this.h, 'inverseProjection', stride, step);
    end
    
    function img = getImageUInt8(this, node, layer, img)
      img = feval(this.m, this.h, 'getImageUInt8', node, layer, img);
    end
    
    function img = getImageDouble(this, node, layer, img)
      img = feval(this.m, this.h, 'getImageDouble', node, layer, img);
    end
  end
end