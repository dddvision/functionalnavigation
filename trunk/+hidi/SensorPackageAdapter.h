#ifndef SENSORPACKAGEADAPTER_H
#define SENSORPACKAGEADAPTER_H

#include "SensorPackage.h"

namespace hidi
{
  class SensorPackageAdapter : public virtual SensorPackage
  {
  private:
    hidi::SensorPackage* source;
  
  public:
    SensorPackageAdapter(hidi::SensorPackage source)
    {
      this->source = source;
    }
  
    virtual void refresh(void)
    {
      source->refresh();
      return;
    }

    virtual std::vector<AccelerometerArray*> getAccelerometerArray(void)
    {
      return (source->getAccelerometerArray());
    }
    
    virtual std::vector<GyroscopeArray*> getGyroscopeArray(void)
    {
      return (source->getGyroscopeArray());
    }

    virtual std::vector<MagnetometerArray*> getMagnetometerArray(void)
    {
      return (source->getMagnetometerArray());
    }

    virtual std::vector<Altimeter*> getAltimeter(void)
    {
      return (source->getAltimeter());
    }

    virtual std::vector<GPSReceiver*> getGPSReceiver(void)
    {
      return (source->getGPSReceiver);
    }
  };
}

#endif
