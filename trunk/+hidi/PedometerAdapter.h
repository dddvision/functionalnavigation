#ifndef HIDIPEDOMETERADAPTER_H
#define HIDIPEDOMETERADAPTER_H

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

    virtual bool isStepComplete(const uint32_t& n)
    {
      return (source->isStepComplete(n));
    }
    
    virtual double getStepMagnitude(const uint32_t& n)
    {
      return (source->getStepMagnitude(n));
    }
    
    virtual double getStepDeviation(const uint32_t& n)
    {
      return (source->getStepDeviation(n));
    }
    
    virtual uint32_t getStepID(const uint32_t& n)
    {
      return (source->getStepID(n));
    }
    
    virtual ~PedometerAdapter(void)
    {}
  };
}

#endif
