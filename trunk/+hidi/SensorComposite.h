#ifndef HIDISENSORCOMPOSITE_H
#define HIDISENSORCOMPOSITE_H

#include <sstream>
#include "GenericSensor.h"

namespace hidi
{
  /**
   * This class wraps a SensorPackage and provides access to each data axis as a GenericSensor.
   */
  class SensorComposite
  {
  private:
    std::vector<hidi::GenericSensor*> sensor;
    std::vector<std::string> sensorLabel;
    
    static std::string num2str(const uint32_t& num)
    {
      std::stringstream s;
      s << num;
      return (s.str());
    }
    
  public:
    /**
     * Constructor.
     *
     * @param[in] package sensor package object
     */
    SensorComposite(hidi::SensorPackage* package)
    {
      uint32_t s;
      uint32_t a;
      std::vector<hidi::AccelerometerArray*> accelerometer = package->getAccelerometerArray();
      std::vector<hidi::Altimeter*> altimeter = package->getAltimeter();
      std::vector<hidi::GPSReceiver*> gpsReceiver = package->getGPSReceiver();
      std::vector<hidi::GyroscopeArray*> gyroscope = package->getGyroscopeArray();
      std::vector<hidi::MagnetometerArray*> magnetometer = package->getMagnetometerArray();

      for(s = 0; s<accelerometer.size(); ++s)
      {
        for(a = 0; a<3; ++a)
        {
          sensor.push_back(new hidi::GenericSensor(ACCELEROMETER_ARRAY, accelerometer[s], a));
          sensorLabel.push_back("Accelerometer["+num2str(s)+"]["+num2str(a)+"]");
        }
      }
      for(s = 0; s<altimeter.size(); ++s)
      {
        sensor.push_back(new hidi::GenericSensor(ALTIMETER, altimeter[s], 0));
        sensorLabel.push_back("Altimeter["+num2str(s)+"]");
      }
      for(s = 0; s<gpsReceiver.size(); ++s)
      {
        for(a = 0; a<3; ++a)
        {
          sensor.push_back(new hidi::GenericSensor(GPS_RECEIVER, gpsReceiver[s], a));
          sensorLabel.push_back("GPSReceiver["+num2str(s)+"]["+num2str(a)+"]");
        }
      }
      for(s = 0; s<gyroscope.size(); ++s)
      {
        for(a = 0; a<3; ++a)
        {
          sensor.push_back(new hidi::GenericSensor(GYROSCOPE_ARRAY, gyroscope[s], a));
          sensorLabel.push_back("Gyroscope["+num2str(s)+"]["+num2str(a)+"]");
        }
      }
      for(s = 0; s<magnetometer.size(); ++s)
      {
        for(a = 0; a<3; ++a)
        {
          sensor.push_back(new hidi::GenericSensor(MAGNETOMETER_ARRAY, magnetometer[s], a));
          sensorLabel.push_back("Magnetometer["+num2str(s)+"]["+num2str(a)+"]");
        }
      }
    }
    
    ~SensorComposite(void)
    {
      uint32_t k;
      for(k = 0; k<sensor.size(); ++k)
      {
        delete sensor[k];
      }
    }
    
    /**
     * Get the number of sensors.
     *
     * @return number of sensors
     */
    uint32_t numSensors(void)
    {
      return(sensor.size());
    }
    
    /**
     * Get data axis as a GenericSensor.
     *
     * @param[in] compositeIndex composite index
     * @return                   generic sensor object
     */
    hidi::GenericSensor* getSensor(const uint32_t& compositeIndex)
    {
      return (sensor[compositeIndex]);
    }
    
    /**
     * Get a label indicating the sensors type, array index, and axis index.
     *
     * @param[in] compositeIndex composite index
     * @return                   label of the form "Type[arrayIndex][axisIndex]"
     */
    std::string getLabel(const uint32_t& compositeIndex)
    {
      return (sensorLabel[compositeIndex]);
    }
  };
}

#endif
