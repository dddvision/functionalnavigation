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
    img = getImageUInt8(this, n, layer, img)
    img = getImageDouble(this, n, layer, img);
  end
end
