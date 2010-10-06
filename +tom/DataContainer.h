#ifndef DATACONTAINER_H
#define DATACONTAINER_H

#include <map>
#include <string>
#include <vector>

#include "Sensor.h"
#include "SensorIndex.h"
#include "Trajectory.h"

namespace tom
{
  /**
   * This class defines a uniform interface to sensor data and ground truth
   *
   * NOTES
   * A component can connect to multiple framework classes
   */
  class DataContainer
  {
  private:
    /**
     * Prevents deep copying
     */
    DataContainer(const DataContainer&)
    {}

    /**
     * Prevents assignment
     */
    DataContainer& operator=(const DataContainer&)
    {}

    /* Storage for component descriptions */
    typedef std::string (*DataContainerDescription)(void);
    static std::map<std::string, DataContainerDescription>* pDescriptionList(void)
    {
      static std::map<std::string, DataContainerDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef DataContainer* (*DataContainerFactory)(const WorldTime);
    static std::map<std::string, DataContainerFactory>* pFactoryList(void)
    {
      static std::map<std::string, DataContainerFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Protected method to construct a singleton component instance
     *
     * @param[in] initialTime less than or equal to the time stamp of the first data node of any sensor
     *
     * NOTES
     * Each subclass constructor must initialize this base class
     * (MATLAB) Initialize by calling this=this@tom.DataContainer;
     */
    DataContainer(const WorldTime initialTime)
    {}

    /**
     * Establish connection between framework class and component
     *
     * @param[in] name component identifier
     * @param[in] cD   function pointer or handle that returns a user friendly description
     * @param[in] cF   function pointer or handle that can instantiate the subclass
     *
     * NOTES
     * The description may be truncated after a few hundred characters when displayed
     * The description should not contain line feed or return characters
     * (C++) Call this function prior to the invocation of main() using an initializer class
     * (MATLAB) Call this function from initialize()
     */
    static void connect(const std::string name, const DataContainerDescription cD, const DataContainerFactory cF)
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
     * Check if a named subclass is connected with this base class
     *
     * @param[in] name component identifier
     * @param[in]      true if the subclass exists and is connected to this base class
     *
     * NOTES
     * Do not shadow this function
     * A package directory identifying the component must in the environment path
     * Omit the '+' prefix when identifying package names
     */
    static bool isConnected(const std::string name)
    {
      return (pFactoryList()->find(name)!=pFactoryList()->end());
    }

    /**
     * Get user friendly description of a component
     *
     * @param[in] name component identifier
     * @return         user friendly description
     *
     * NOTES
     * Do not shadow this function
     * If the component is not connected then the output is an empty string
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
     * Public method to construct a singleton component instance
     *
     * @param[in] initialTime less than or equal to the time stamp of the first data node of any sensor
     * @param[in] name component identifier
     * @return         singleton object instance that should not be deleted
     *
     * NOTES
     * Do not shadow this function
     * Throws an error if the component is not connected
     */
    static DataContainer* create(const WorldTime initialTime, const std::string name)
    {
      static DataContainer* singleton = NULL;
      static std::string identifier = "";

      if(isConnected(name))
      {
        if(singleton==NULL)
        {
          singleton = (*pFactoryList())[name](initialTime);
          identifier = name;
        }
        else if(name.compare(identifier))
        {
          throw("This singleton class must receive the same ''name'' argument every time it is called");
        }
      }
      else
      {
        throw("The requested component is not connected");
      }
      return (singleton);
    }

    /**
     * Initializes connections between a component and one or more framework classes
     *
     * @param[in] name component identifier
     *
     * NOTES
     * (C++) Does nothing and does not require implementation
     * (MATLAB) Implement this as a static function that calls connect()
     */
    static void initialize(std::string name)
    {}

    /**
     * List available sensors of a given class
     *
     * @param[in] type class identifier
     * @return         list of unique sensor identifiers (MATLAB: N-by-1)
     *
     * NOTES
     * Sensors that inherit from the given class will also be included in the output list
     * To list all, use type='Sensor'
     */
    virtual std::vector<SensorIndex> listSensors(const std::string type) = 0;

    /**
     * Get sensor description
     *
     * @param[in] id zero-based index
     * @return       user friendly sensor description
     *
     * NOTES
     * Description may be truncated after a few hundred characters when displayed
     * Description should be unique within a DataContainer
     * Avoid using line feed or return characters
     * Throws an exception if input index is out of range
     */
    virtual std::string getSensorDescription(SensorIndex) = 0;

    /**
     * Get instance of a Sensor
     *
     * @param[in] id zero-based index
     * @return       object instance
     *
     * NOTES
     * The specific subclass of the output depends on the given identifier
     * Throws an exception if input index is out of range
     */
    virtual Sensor& getSensor(SensorIndex) = 0;

    /**
     * Check whether a refernce trajectory is available
     *
     * @return true if available and false otherwise
     */
    virtual bool hasReferenceTrajectory(void) = 0;

    /**
     * Get reference trajectory
     *
     * @return object instance
     *
     * NOTES
     * The body follows this trajectory while recording sensor data
     * Throws an exception if trajectory is not available
     */
    virtual Trajectory& getReferenceTrajectory(void) = 0;
    
    /**
     * Virtual base class destructor
     */
    virtual ~DataContainer(void)
    {}
  };
}

#endif
