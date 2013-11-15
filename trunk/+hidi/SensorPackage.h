#ifndef HIDISENSORPACKAGE_H
#define HIDISENSORPACKAGE_H

#include <cstdlib>
#include <map>
#include <string>
#include <vector>
#include "AccelerometerArray.h"
#include "Altimeter.h"
#include "Camera.h"
#include "GPSReceiver.h"
#include "GyroscopeArray.h"
#include "MagnetometerArray.h"
#include "Pedometer.h"

namespace hidi
{
  /**
   * This class is a container for several sensor types.
   *
   * @note
   * The following sensor types are included:
   *   AccelerometerArray
   *   Altimeter
   *   Camera
   *   GPSReceiver
   *   GyroscopeArray
   *   MagnetometerArray
   *   Pedometer
   *
   * The following sensor types are not included:
   *   GenericSensor
   */
  class SensorPackage
  {
  private:
    /**
     * Prevents deep copying.
     */
    SensorPackage(const SensorPackage&);

    /**
     * Prevents assignment.
     */
    SensorPackage& operator=(const SensorPackage&);

    /* Storage for package descriptions */
    typedef std::string (*SensorPackageDescription)(void);
    static std::map<std::string, SensorPackageDescription>& pDescriptionList(void)
    {
      static std::map<std::string, SensorPackageDescription> descriptionList;
      return descriptionList;
    }

    /* Storage for package factories */
    typedef SensorPackage* (*SensorPackageFactory)(const std::string&);
    static std::map<std::string, SensorPackageFactory>& pFactoryList(void)
    {
      static std::map<std::string, SensorPackageFactory> factoryList;
      return factoryList;
    }

  protected:
    /**
     * Protected constructor.
     */
    SensorPackage(void)
    {}

    /**
     * Establish connection between base class and specific package.
     *
     * @param[in] name package identifier
     * @param[in] cD   function pointer or handle that returns a user friendly description
     * @param[in] cF   function pointer or handle that can instantiate the subclass
     *
     * @note
     * The description may be truncated after a few hundred characters when displayed.
     * The description should not contain line feed or return characters.
     * (C++) Call this function prior to the invocation of main() using an initializer class.
     * (MATLAB) Call this function from initialize().
     */
    static void connect(const std::string& name, const SensorPackageDescription& cD, const SensorPackageFactory& cF)
    {
      if(!((cD==NULL)|(cF==NULL)))
      {
        pDescriptionList()[name] = cD;
        pFactoryList()[name] = cF;
      }
      return;
    }

  public:
    /**
     * Check if a named subclass is connected with this base class.
     *
     * @param[in] name package identifier
     * @return         true if the subclass exists and is connected to this base class
     *
     * @note
     * Do not shadow this function.
     * A package directory identifying the package must in the environment path.
     * Omit the '+' prefix when identifying package names.
     */
    static bool isConnected(const std::string& name)
    {
      return (pFactoryList().find(name)!=pFactoryList().end());
    }

    /**
     * Get user friendly description of a package.
     *
     * @param[in] name package identifier
     * @return         user friendly description
     *
     * @note
     * Do not shadow this function.
     * Throws an error if the package is not connected.
     */
    static std::string description(const std::string& name)
    {
      static std::string message;
      std::string str = "";
      if(isConnected(name))
      {
        str = pDescriptionList()[name]();
      }
	  else
      {
        message = "SensorPackage: '";
        message = message+name;
        message = message+"' is not connected. Its static initializer must call connect.";
        throw(message.c_str());
      }
      return (str);
    }

    /**
     * Public method to construct a package instance.
     *
     * @para[in]  name       package name
     * @param[in] parameters semicolon separated pairs of the format [<key0>=<value0>[;<key1>=<value1>]]
     * @return               pointer to a new instance
     *
     * @note
     * Hardware implementation is supported by recognizing system resources such as 'uri=file://dev/ttyS0'.
     * Creates a new instance that must be deleted by the caller.
     * Do not shadow this function.
     * Throws an error if the package is not connected.
     */
    static SensorPackage* create(const std::string& name, const std::string& parameters)
    {
      static std::string message;
      SensorPackage* obj = NULL;
      if(isConnected(name))
      {
        obj = pFactoryList()[name](parameters);
      }
      else
      {
        message = "SensorPackage: '";
        message = message+name;
        message = message+"' is not connected. Its static initializer must call connect.";
        throw(message.c_str());
      }
      return (obj);
    }

    /**
     * Split compound URI into parts.
     *
     * @param[in]  uri         URI of the format: hidi:<packageName>[?<parameters>]
     * @param[out] packageName substring containing packageName
     * @param[out] parameters  substring containing parameters
     */
    static void splitCompoundURI(const std::string& uri, std::string& packageName, std::string& parameters)
    {
      size_t delimeter;
      packageName = uri;
      parameters = "";
      delimeter = packageName.find(':');
      if(delimeter==std::string::npos)
      {
        throw("SensorPackage: Expected URI format: scheme:<packageName>[?<key0>=<value0>[;<key1>=<value1>]]");
      }
      packageName = packageName.substr(delimeter+1);
      delimeter = packageName.find('?');
      if(delimeter==std::string::npos)
      {
        return;
      }
      parameters = packageName.substr(delimeter+1);
      packageName = packageName.substr(0, delimeter);
      return;
    }

    /**
     * Get parameter from string.
     *
     * @param[in] parameters see SensorPackage::create()
     * @param[in] key        see SensorPackage::create()
     * @return               string value of the selected parameter
     *
     * @note
     * Returns empty string if the key is not found.
     * The special key 'uri' causes the remainder of the string to be returned ignoring semicolons.
     */
    static std::string getParameter(const std::string& parameters, const std::string& key)
    {
      size_t delimeter;
      std::string str = "";
      if(key.size()==0)
      {
        return (str);
      }
      delimeter = parameters.find(key+"=");
      if(delimeter==std::string::npos)
      {
        return (str);
      }
      str = parameters.substr(delimeter+key.size()+1);
      if(key.compare("uri"))
      {
        delimeter = str.find(';');
        if(delimeter!=std::string::npos)
        {
          str = str.substr(0, delimeter);
        }
      }
      return (str);
    }
    
    /**
     * Get double parameter from string.
     *
     * @param[in] parameters see SensorPackage::create()
     * @param[in] key        see SensorPackage::create()
     * @return               numeric value of the selected parameter
     *
     * @note
     * Returns NAN if the value is not present.
     * Returns 0.0 if the value cannot be converted.
     */
    static double getDoubleParameter(const std::string& parameters, const std::string& key)
    {
      std::string str;
      double value;
      str = SensorPackage::getParameter(parameters, key);
      if(str.empty())
      {
        value = NAN;
      }
      else
      {
        value = strtod(str.c_str(), NULL);
        if((value==HUGE_VAL)||(value==-HUGE_VAL))
        {
          value = 0.0;
        }
      }
      return (value);
    }
    
    /**
     * Refresh all sensors in the package.
     */
    void refresh(void)
    {
      std::vector<AccelerometerArray*> accelerometerArray = getAccelerometerArray();
      std::vector<Altimeter*> altimeter = getAltimeter();
      std::vector<Camera*> camera = getCamera();
      std::vector<GPSReceiver*> gpsReceiver = getGPSReceiver();
      std::vector<GyroscopeArray*> gyroscopeArray = getGyroscopeArray();
      std::vector<MagnetometerArray*> magnetometerArray = getMagnetometerArray();
      std::vector<Pedometer*> pedometer = getPedometer();
      size_t n;
      for(n = 0; n<accelerometerArray.size(); ++n)
      {
        accelerometerArray[n]->refresh();
      }
      for(n = 0; n<altimeter.size(); ++n)
      {
        altimeter[n]->refresh();
      }
      for(n = 0; n<camera.size(); ++n)
      {
        camera[n]->refresh();
      }
      for(n = 0; n<gpsReceiver.size(); ++n)
      {
        gpsReceiver[n]->refresh();
      }
      for(n = 0; n<gyroscopeArray.size(); ++n)
      {
        gyroscopeArray[n]->refresh();
      }
      for(n = 0; n<magnetometerArray.size(); ++n)
      {
        magnetometerArray[n]->refresh();
      }
      for(n = 0; n<pedometer.size(); ++n)
      {
        pedometer[n]->refresh();
      }
      return;
    }

    /**
     * Get accelerometer array.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<AccelerometerArray*> getAccelerometerArray(void)
    {
      std::vector<AccelerometerArray*> sensor(0);
      return (sensor);
    }

    /**
     * Get altimeter.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<Altimeter*> getAltimeter(void)
    {
      std::vector<Altimeter*> sensor(0);
      return (sensor);
    }
    
    /**
     * Get camera.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<Camera*> getCamera(void)
    {
      std::vector<Camera*> sensor(0);
      return (sensor);
    }
    
    /**
     * Get GPS receiver.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<GPSReceiver*> getGPSReceiver(void)
    {
      std::vector<GPSReceiver*> sensor(0);
      return (sensor);
    }
    
    /**
     * Get gyroscope array.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<GyroscopeArray*> getGyroscopeArray(void)
    {
      std::vector<GyroscopeArray*> sensor(0);
      return (sensor);
    }

    /**
     * Get magnetometer array.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<MagnetometerArray*> getMagnetometerArray(void)
    {
      std::vector<MagnetometerArray*> sensor(0);
      return (sensor);
    }
    
    /**
     * Get Pedometer.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<Pedometer*> getPedometer(void)
    {
      std::vector<Pedometer*> sensor(0);
      return (sensor);
    }

    /**
     * Virtual base class destructor.
     */
    virtual ~SensorPackage(void)
    {}
  };
}

#endif
