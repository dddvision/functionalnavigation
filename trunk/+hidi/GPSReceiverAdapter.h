#ifndef GPSRECEIVERADAPTER_H
#define GPSRECEIVERADAPTER_H

#include "GPSReceiver.h"
#include "SensorAdapter.h"

namespace hidi
{
  class GPSReceiverAdapter : public virtual hidi::GPSReceiver, public hidi::SensorAdapter
  {
  private:
    hidi::GPSReceiver* source;

  public:
    GPSReceiverAdapter(hidi::GPSReceiver* source) : SensorAdapter(source)
    {
      this->source = source;
    }

    virtual double getLongitude(uint32_t n)
    {
      return (source->getLongitude(n));
    }
    
    virtual double getLatitude(uint32_t n)
    {
      return (source->getLatitude(n));
    }
    
    virtual double getHeight(uint32_t n)
    {
      return (source->getHeight(n));
    }
    
    virtual bool hasPrecision(void)
    {
      return (source->hasPrecision());
    }
    
    virtual double getPrecisionHorizontal(uint32_t n)
    {
      return (source->getPrecisionHorizontal(n));
    }

    virtual double getPrecisionVertical(uint32_t n)
    {
      return (source->getPrecisionVertical(n));
    }
    
    virtual double getPrecisionCircular(uint32_t n)
    {
      return (source->getPrecisionCircular(n));
    }
  };
}
  
#endif
