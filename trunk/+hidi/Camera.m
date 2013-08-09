classdef Camera < hidi.Sensor 
  methods (Access = public, Abstract = true)
    num = numStrides(this);
    num = numSteps(this);
    str = interpretLayers(this);
    pix = projection(this, ray);
    ray = inverseProjection(this, pix);
    s = strideMin(this);
    s = strideMax(this);
    s = stepMin(this);
    s = stepMax(this);
    img = getImageUInt8(this, n)
    img = getImageDouble(this, n);
  end
end
