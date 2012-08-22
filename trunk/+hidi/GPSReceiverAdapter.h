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

    virtual double getHDOP(const uint32_t& n)
    {
      return (source->getHDOP(n));
    }

    virtual double getVDOP(const uint32_t& n)
    {
      return (source->getVDOP(n));
    }

    virtual double getPDOP(const uint32_t& n)
    {
      return (source->getPDOP(n));
    }
    
    virtual ~GPSReceiverAdapter(void)
    {}
  };
}

#endif
