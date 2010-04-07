#ifndef DATACONTAINER_H
#define DATACONTAINER_H

#include "tommas.h"
#include "Sensor.h"
#include "Trajectory.h"

namespace tommas
{
  class DataContainer
  {
  public:
    static const std::string frameworkClass="DataContainer";
    static DataContainer* factory(const std::string dataContainerName)
    {
      static DataContainer* singleton=NULL;
      if(!singleton)
      {
        singleton=dataContainerList[dataContainerName](void);
      }
      return singleton;
    }
  
  protected:
    DataContainer(void);

  public:
    virtual std::string getDescription(void);    
    virtual std::vector<SensorID> listSensors(const std::string);
    virtual std::string getSensorDescription(SensorID);
    virtual Sensor getSensor(SensorID); // return Sensor*?
    virtual bool hasReferenceTrajectory(void);
    virtual Trajectory getReferenceTrajectory(this); // return Trajectory*?
  };
}

#endif

