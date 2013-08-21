#ifndef HIDICAMERAADAPTER_H
#define HIDICAMERAADAPTER_H

#include "Camera.h"
#include "SensorAdapter.h"

namespace hidi
{
  class CameraAdapter : public virtual hidi::Camera, public hidi::SensorAdapter
  {
  private:
    hidi::Camera* source;

  public:
    CameraAdapter(hidi::Camera* source) :
      SensorAdapter(source)
    {
      this->source = source;
    }

    virtual std::string interpretLayers(void)
    {
      return (source->interpretLayers());
    }

    virtual uint32_t numStrides(void)
    {
      return (source->numStrides());
    }

    virtual uint32_t numSteps(void)
    {
      return (source->numSteps());
    }

    virtual uint32_t strideMin(const uint32_t& node)
    {
      return (source->strideMin(node));
    }

    virtual uint32_t strideMax(const uint32_t& node)
    {
      return (source->strideMax(node));
    }

    virtual uint32_t stepMin(const uint32_t& node)
    {
      return (source->stepMin(node));
    }

    virtual uint32_t stepMax(const uint32_t& node)
    {
      return (source->stepMax(node));
    }
    
    virtual void projection(const double& forward, const double& right, const double& down, double& stride, 
      double& step)
    {
      source->projection(forward, right, down, stride, step);
      return;
    }

    virtual void inverseProjection(const double& stride, const double& step, double& forward, double& right, 
      double& down)
    {
      source->inverseProjection(stride, step, forward, right, down);
      return;
    }

    virtual void getImageUInt8(const uint32_t& node, const uint32_t& layer, std::vector<uint8_t>& img)
    {
      source->getImageUInt8(node, layer, img);
      return;
    }
    
    virtual void getImageDouble(const uint32_t& node, const uint32_t& layer, std::vector<double>& img)
    {
      source->getImageDouble(node, layer, img);
      return;
    }
    
    virtual ~CameraAdapter(void)
    {}
  };
}

#endif
