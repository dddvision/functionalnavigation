#ifndef PEDOMETERADAPTER_H
#define PEDOMETERADAPTER_H

#include "Pedometer.h"
#include "SensorAdapter.h"

namespace hidi
{
  class PedometerAdapter : public virtual hidi::Pedometer, public hidi::SensorAdapter
  {
  private:
    hidi::Pedometer* source;

  public:
    PedometerAdapter(hidi::Pedometer* source) :
      SensorAdapter(source)
    {
      this->source = source;
    }

    virtual bool isComplete(const uint32_t& node)
    {
      return (source->isComplete(node));
    }
    
    virtual double getMagnitude(const uint32_t& node)
    {
      return (source->getMagnitude(node));
    }
    
    virtual double getDeviation(const uint32_t& node)
    {
      return (source->getDeviation(node));
    }
    
    virtual StepLabel getLabel(const uint32_t& node)
    {
      return (source->getLabel(node));
    }
    
    virtual ~PedometerAdapter(void)
    {}
  };
}

#endif
