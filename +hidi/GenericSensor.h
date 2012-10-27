#ifndef HIDIGENERICSENSOR_H
#define HIDIGENERICSENSOR_H

#include "SensorType.h"

namespace hidi
{
  class GenericSensor : hidi::Sensor
  {
  private:
    hidi::SensorType sensorType;
    hidi::Sensor* sensor;
    uint32_t axisIndex; 

  public:
    GenericSensor(const hidi::SensorType& sensorType, hidi::Sensor* sensor, const uint32_t& axisIndex)
    {
      this->sensorType = sensorType;
      this->sensor = sensor;
      this->axisIndex = axisIndex;
    }

    void refresh(void)
    {}

    bool hasData(void)
    {
      return (sensor->hasData());
    }

    uint32_t first(void)
    {
      return (sensor->first());
    }

    uint32_t last(void)
    {
      return (sensor->last());
    }

    double getTime(const uint32_t& node)
    {
      return (sensor->getTime(node));
    }

    double getData(const uint32_t& node)
    {
      double data;
      switch(sensorType)
      {
        case ACCELEROMETER_ARRAY:
          data = dynamic_cast<hidi::AccelerometerArray*>(sensor)->getSpecificForce(node, axisIndex);
          break;
        case GYROSCOPE_ARRAY:
          data = dynamic_cast<hidi::GyroscopeArray*>(sensor)->getAngularRate(node, axisIndex);
          break;
        case MAGNETOMETER_ARRAY:
          data = dynamic_cast<hidi::MagnetometerArray*>(sensor)->getMagneticField(node, axisIndex);
          break;
        case ALTIMETER:
          data = dynamic_cast<hidi::Altimeter*>(sensor)->getAltitude(node);
          break;
        case GPS_RECEIVER:
        {
          switch(axisIndex)
          {
            case 0:
              data = dynamic_cast<hidi::GPSReceiver*>(sensor)->getLongitude(node);
              break;
            case 1:
              data = dynamic_cast<hidi::GPSReceiver*>(sensor)->getLatitude(node);
              break;
            case 2:
              data = dynamic_cast<hidi::GPSReceiver*>(sensor)->getHeight(node);
              break;
            default:
              throw("ExtractNorms: Sensor axis index out of range.");
          }
          break;
        default:
          throw("ExtractNorms: Invalid sensor type.");
        }
      }
      return (data);
    }
  };
}
  
#endif
