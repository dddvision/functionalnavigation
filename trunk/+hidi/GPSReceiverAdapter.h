#ifndef HIDIGPSRECEIVERADAPTER_H
#define HIDIGPSRECEIVERADAPTER_H

#include "GPSReceiver.h"
#include "SensorAdapter.h"

namespace hidi
{
  class GPSReceiverAdapter : public virtual hidi::GPSReceiver, public hidi::SensorAdapter
  {
  private:
    hidi::GPSReceiver* source;

  public:
    GPSReceiverAdapter(hidi::GPSReceiver* source) :
      SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getLongitude(const uint32_t& n)
    {
      return (source->getLongitude(n));
    }

    virtual double getLatitude(const uint32_t& n)
    {
      return (source->getLatitude(n));
    }

    virtual double getHeight(const uint32_t& n)
    {
      return (source->getHeight(n));
    }

    virtual bool hasPrecision(void)
    {
      return (source->hasPrecision());
    }

    virtual double getPrecisionHorizontal(const uint32_t& n)
    {
      return (source->getPrecisionHorizontal(n));
    }

    virtual double getPrecisionVertical(const uint32_t& n)
    {
      return (source->getPrecisionVertical(n));
    }

    virtual double getPrecisionCircular(const uint32_t& n)
    {
      return (source->getPrecisionCircular(n));
    }
    
    virtual ~GPSReceiverAdapter(void)
    {}
  };
}

#endif
