#ifndef HIDISENSORADAPTER_H
#define HIDISENSORADAPTER_H

#include "Sensor.h"

namespace hidi
{
  class SensorAdapter : public virtual hidi::Sensor
  {
  private:
    hidi::Sensor* source;

  public:
    SensorAdapter(hidi::Sensor* source)
    {
      this->source = source;
    }

    virtual void refresh(void)
    {
      source->refresh();
      return;
    }

    virtual bool hasData(void)
    {
      return (source->hasData());
    }

    virtual uint32_t first(void)
    {
      return (source->first());
    }

    virtual uint32_t last(void)
    {
      return (source->last());
    }

    virtual double getTime(const uint32_t& n)
    {
      return (source->getTime(n));
    }
    
    virtual ~SensorAdapter(void)
    {}
  };
}

#endif
