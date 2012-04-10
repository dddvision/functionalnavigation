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

    /* Storage for component descriptions */
    typedef std::string (*SensorPackageDescription)(void);
    static std::map<std::string, SensorPackageDescription>* pDescriptionList(void)
    {
      static std::map<std::string, SensorPackageDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef SensorPackage* (*SensorPackageFactory)(const std::string);
    static std::map<std::string, SensorPackageFactory>* pFactoryList(void)
    {
      static std::map<std::string, SensorPackageFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Protected method to construct a component instance.
     *
     * @param[in] uri uniform resource identifier as described below
     *
     * @note
     * Hardware implementation is supported by recognizing system resources such as 'file://dev/ttyS0'.
     * Each subclass constructor must initialize this base class.
     * (MATLAB) Initialize by calling:
     * @code
     *   this=this@hidi.SensorPackage(uri);
     * @endcode
     */
    SensorPackage(const std::string uri)
    {}

    /**
     * Establish connection between base class and specific component.
     *
     * @param[in] name component identifier
     * @param[in] cD   function pointer or handle that returns a user friendly description
     * @param[in] cF   function pointer or handle that can instantiate the subclass
     *
     * @note
     * The description may be truncated after a few hundred characters when displayed.
     * The description should not contain line feed or return characters.
     * (C++) Call this function prior to the invocation of main() using an initializer class.
     * (MATLAB) Call this function from initialize().
     */
    static void connect(const std::string name, const SensorPackageDescription cD, const SensorPackageFactory cF)
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
     * @param[in] name component identifier
     * @return         true if the subclass exists and is connected to this base class
     *
     * @note
     * Do not shadow this function.
     * A package directory identifying the component must in the environment path.
     * Omit the '+' prefix when identifying package names.
     */
    static bool isConnected(const std::string name)
    {
      return (pFactoryList()->find(name)!=pFactoryList()->end());
    }

    /**
     * Get user friendly description of a component.
     *
     * @param[in] name component identifier
     * @return         user friendly description
     *
     * @note
     * Do not shadow this function.
     * If the component is not connected then the output is an empty string.
     */
    static std::string description(const std::string name)
    {
      std::string str = "";
      if(isConnected(name))
      {
        str = (*pDescriptionList())[name]();
      }
      return (str);
    }

    /**
     * Public method to construct a component instance.
     *
     * @param[in] name component identifier
     * @param[in] uri  see SensorPackage constructor
     * @return         pointer to a new instance
     *
     * @note
     * Creates a new instance that must be deleted by the caller.
     * Do not shadow this function.
     * Throws an error if the component is not connected.
     */
    static SensorPackage* create(const std::string name, const std::string uri)
    {

      SensorPackage* obj = NULL;
      if(isConnected(name))
      {
        obj = (*pFactoryList())[name](uri);
      }
      else
      {
        std::string message = "\""+name+"\" is not connected. Its static initializer must call connect.";
        throw(message.c_str());
      }
      return (obj);
    }

    /**
     * Incorporate new data and allow old data to expire for all sensors in the package.
     *
     * @note
     * This function updates the object state without waiting for new data to be acquired.
     */
    virtual void refresh(void) = 0;

    /**
     * Get accelerometer array.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<AccelerometerArray*> getAccelerometerArray(void) = 0;

    /**
     * Get gyroscope array.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<GyroscopeArray*> getGyroscopeArray(void) = 0;

    /**
     * Get magnetometer array.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<MagnetometerArray*> getMagnetometerArray(void) = 0;

    /**
     * Get altimeter.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<Altimeter*> getAltimeter(void) = 0;

    /**
     * Get GPS receiver.
     *
     * @return vector of pointers to shared resources (do not delete)
     */
    virtual std::vector<GPSReceiver*> getGPSReceiver(void) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~SensorPackage(void)
    {}
  };
}

#endif
