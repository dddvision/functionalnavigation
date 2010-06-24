#ifndef DATACONTAINER_H
#define DATACONTAINER_H

#include <map>
#include <string>
#include <vector>

#include "Sensor.h"
#include "SensorIndex.h"
#include "Trajectory.h"

namespace tommas
{
  class DataContainer;
  typedef DataContainer* (*DataContainerFactory)(void);
  extern std::map<std::string,DataContainerFactory> dataContainerList;
  
  class DataContainer
  {
  private:
    DataContainer(const DataContainer&){}
    
  protected:
    DataContainer(void){}
    ~DataContainer(void){}
    
  public:
    virtual std::string getDescription(void) = 0;
    virtual std::vector<SensorIndex> listSensors(const std::string) = 0;
    virtual std::string getSensorDescription(SensorIndex) = 0;  
    virtual Sensor& getSensor(SensorIndex) = 0;
    virtual bool hasReferenceTrajectory(void) = 0;
    virtual Trajectory& getReferenceTrajectory(void) = 0;
    
    static std::string frameworkClass(void) { return std::string("DataContainer"); }
    static DataContainer* factory(const std::string dataContainerName)
    {
      static DataContainer* singleton = NULL;
      if(!singleton)
      {
        if(dataContainerList.find(dataContainerName) != dataContainerList.end())
        {
          singleton=dataContainerList[dataContainerName]();
        }
      }
      return singleton;
    }
  };
}

#endif
