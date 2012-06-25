#ifndef SENSORPACKAGE_H
#define SENSORPACKAGE_H

#include <map>
#include <string>
#include <vector>
#include "AccelerometerArray.h"
#include "GyroscopeArray.h"
#include "MagnetometerArray.h"
#include "Altimeter.h"
#include "GPSReceiver.h"

namespace hidi
{
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
    static std::map<std::string, SensorPackageDescription>* pDescriptionList(void)
    {
      static std::map<std::string, SensorPackageDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for package factories */
    typedef SensorPackage* (*SensorPackageFactory)(const std::string&);
    static std::map<std::string, SensorPackageFactory>* pFactoryList(void)
    {
      static std::map<std::string, SensorPackageFactory> factoryList;
      return &factoryList;
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
        (*pDescriptionList())[name] = cD;
        (*pFactoryList())[name] = cF;
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
      return (pFactoryList()->find(name)!=pFactoryList()->end());
    }

    /**
     * Get user friendly description of a package.
     *
     * @param[in] name package identifier
     * @return         user friendly description
     *
     * @note
     * Do not shadow this function.
     * If the package is not connected then the output is an empty string.
     */
    static std::string description(const std::string& name)
    {
      std::string str = "";
      if(isConnected(name))
      {
        str = (*pDescriptionList())[name]();
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
        obj = (*pFactoryList())[name](parameters);
      }
      else
      {
        message = "SensorPackage: \"";
        message = message+name;
        message = message+"\" is not connected. Its static initializer must call connect.";
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
      if(packageName.compare(0, 5, "hidi:"))
      {
        throw("SensorPackage: Expected URI format: hidi:<packageName>[?<key0>=<value0>[;<key1>=<value1>]]");
      }
      packageName = packageName.substr(5);
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
     * @return               value of the selected parameter
     *
     * @note
     * The special key 'uri' causes the remainder of the string to be returned ignoring semicolons.
     */
    static std::string getParameter(const std::string& parameters, const std::string& key)
    {
      size_t delimeter;
      std::string value = "";
      if(key.size()==0)
      {
        return (value);
      }
      delimeter = parameters.find(key+"=");
      if(delimeter==std::string::npos)
      {
        return (value);
      }
      value = parameters.substr(delimeter+key.size()+1);
      if(key.compare("uri"))
      {
        delimeter = value.find(';');
        if(delimeter!=std::string::npos)
        {
          value = value.substr(0, delimeter);
        }
      }
      return (value);
    }
    
    /**
     * Refresh all sensors in the package.
     */
    void refresh(void)
    {
      static std::vector<AccelerometerArray*> accelerometerArray = getAccelerometerArray();
      static std::vector<GyroscopeArray*> gyroscopeArray = getGyroscopeArray();
      static std::vector<MagnetometerArray*> magnetometerArray = getMagnetometerArray();
      static std::vector<Altimeter*> altimeter = getAltimeter();
      static std::vector<GPSReceiver*> gpsReceiver = getGPSReceiver();
      size_t n;
      for(n = 0; n<accelerometerArray.size(); ++n)
      {
        accelerometerArray[n]->refresh();
      }
      for(n = 0; n<gyroscopeArray.size(); ++n)
      {
        gyroscopeArray[n]->refresh();
      }
      for(n = 0; n<magnetometerArray.size(); ++n)
      {
        magnetometerArray[n]->refresh();
      }
      for(n = 0; n<altimeter.size(); ++n)
      {
        altimeter[n]->refresh();
      }
      for(n = 0; n<gpsReceiver.size(); ++n)
      {
        gpsReceiver[n]->refresh();
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
     * Virtual base class destructor.
     */
    virtual ~SensorPackage(void)
    {}
  };
}

#endif
