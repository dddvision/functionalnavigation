#ifndef SENSORPACKAGEADAPTER_H
#define SENSORPACKAGEADAPTER_H

#include "SensorPackage.h"
#include "AccelerometerArrayAdapter.h"
#include "GyroscopeArrayAdapter.h"
#include "MagnetometerArrayAdapter.h"
#include "AltimeterAdapter.h"
#include "GPSReceiverAdapter.h"
#include "PedometerAdapter.h"

namespace hidi
{
  class SensorPackageAdapter : public virtual SensorPackage
  {
  private:
    hidi::SensorPackage* source;

  public:
    SensorPackageAdapter(hidi::SensorPackage* source)
    {
      this->source = source;
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
      return (source->getGPSReceiver());
    }
    
    virtual std::vector<Pedometer*> getPedometer(void)
    {
      return (source->getPedometer());
    }

    virtual ~SensorPackageAdapter(void)
    {}
  };
}

#endif
