#ifndef DATACONTAINER_H
#define DATACONTAINER_H

#include "tommas.h"

namespace tommas
{
  typedef unsigned int SensorID;
  
  class DataContainer;
  typedef DataContainer* (*DataContainerFactory)(void);
  extern std::map<std::string,DataContainerFactory> dataContainerList;
  
  class DataContainer
  {
  protected:
    DataContainer(void){}
    
  public:
    virtual std::string getDescription(void) = 0;
    virtual std::vector<SensorID> listSensors(const std::string) = 0;
    virtual std::string getSensorDescription(SensorID) = 0;  
    virtual Sensor& getSensor(SensorID) = 0; // return Sensor*?
    virtual bool hasReferenceTrajectory(void) = 0;
    virtual Trajectory& getReferenceTrajectory(void) = 0; // return Trajectory*?
    
    static std::string frameworkClass(void) { return std::string("DataContainer"); }
    static DataContainer* factory(const std::string dataContainerName)
    {
      static DataContainer* dataContainerSingleton = NULL;
      if(!dataContainerSingleton)
      {
        if(dataContainerList.find(dataContainerName) == dataContainerList.end())
        { 
          std::cerr << dataContainerName << " not found in data container list" << std::endl;
        }
        else { dataContainerSingleton=dataContainerList[dataContainerName](); }
      }
      return dataContainerSingleton;
    }
  };
}

#endif

