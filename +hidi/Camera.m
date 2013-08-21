classdef Camera < hidi.Sensor 
  methods (Access = public, Abstract = true)
    str = interpretLayers(this);
    num = numStrides(this);
    num = numSteps(this);
    stride = strideMin(this, node);
    stride = strideMax(this, node);
    step = stepMin(this, node);
    step = stepMax(this, node);
    [stride, step] = projection(this, forward, right, down);
    [forward, right, down] = inverseProjection(this, stride, step);
    img = getImageUInt8(this, node, layer, img);
    img = getImageDouble(this, node, layer, img);
  end
end
