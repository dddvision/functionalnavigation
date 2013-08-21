#ifndef HIDIGENERICSENSOR_H
#define HIDIGENERICSENSOR_H

#include "SensorType.h"

namespace hidi
{
  /**
   * This class wraps a single axis of a specific sensor and provides generic data access.
   */
  class GenericSensor : hidi::Sensor
  {
  private:
    hidi::SensorType sensorType;
    hidi::Sensor* sensor;
    uint32_t axisIndex; 

  public:
    /**
     * Constructor.
     *
     * @param[in] sensorType sensor type
     * @param[in] sensor     sensor object
     * @param[in] axisIndex  axis index
     */
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

    /**
     * Get generic data.
     * 
     * @param[in] n data index (MATLAB: M-by-N)
     * @return      generic data (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if any index is out of range.
     */
    double getData(const uint32_t& node)
    {
      double data;
      switch(sensorType)
      {
        case ACCELEROMETER_ARRAY:
          data = dynamic_cast<hidi::AccelerometerArray*>(sensor)->getSpecificForce(node, axisIndex);
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
              throw("GenericSensor: Sensor axis index out of range.");
          }
          break;
        case GYROSCOPE_ARRAY:
          data = dynamic_cast<hidi::GyroscopeArray*>(sensor)->getAngularRate(node, axisIndex);
          break;
        case MAGNETOMETER_ARRAY:
          data = dynamic_cast<hidi::MagnetometerArray*>(sensor)->getMagneticField(node, axisIndex);
          break;
        default:
          throw("GenericSensor: Invalid sensor type.");
        }
      }
      return (data);
    }
  };
}
  
#endif
