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
  class DataContainer
  {
  private:
    DataContainer(const DataContainer&){} 

    typedef std::string (*DataContainerDescription)(void);
    static std::map<std::string,DataContainerDescription>* pDescriptionList(void)
    {
      static std::map<std::string,DataContainerDescription> descriptionList;
      return &descriptionList;
    }

    typedef DataContainer* (*DataContainerFactory)(void);
    static std::map<std::string,DataContainerFactory>* pFactoryList(void)
    {
      static std::map<std::string,DataContainerFactory> factoryList;
      return &factoryList;
    }

  protected:
    DataContainer(void){}
    ~DataContainer(void){}
    
  public:
    static void connect(const std::string name, const DataContainerDescription cD, const DataContainerFactory cF)
    {
      if(!((cD==NULL)|(cF==NULL)))
      {
        (*pDescriptionList())[name]=cD;
        (*pFactoryList())[name]=cF;
      }
      return;
    }
    
    static bool isConnected(const std::string name)
    {
      return(pFactoryList()->find(name) != pFactoryList()->end());
    }

    static std::string description(const std::string name)
    {
      std::string str="";
      if(isConnected(name))
      {
        str=(*pDescriptionList())[name]();
      }
      return(str);
    }

    static DataContainer* factory(const std::string name)
    {
      static DataContainer* singleton = NULL;
      if(singleton==NULL)
      {
        if(isConnected(name))
        {
          singleton=(*pFactoryList())[name]();
        }
        else
        {
          throw("DataContainer is not connected to the requested component");
        }
      }
      return(singleton);
    }

    virtual std::vector<SensorIndex> listSensors(const std::string) = 0;
    virtual std::string getSensorDescription(SensorIndex) = 0;  
    virtual Sensor& getSensor(SensorIndex) = 0;
    virtual bool hasReferenceTrajectory(void) = 0;
    virtual Trajectory& getReferenceTrajectory(void) = 0;
  };
}

#endif
