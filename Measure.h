#ifndef MEASURE_H
#define MEASURE_H

#include <map>
#include <string>
#include <vector>

#include "GraphEdge.h"
#include "Trajectory.h"
#include "Sensor.h"

namespace tommas
{ 
  class Measure : public Sensor
  {
  private:
    Measure(const Measure&){}

    typedef std::string (*MeasureDescription)(void);
    static std::map<std::string,MeasureDescription>* pDescriptionList(void)
    {
      static std::map<std::string,MeasureDescription> descriptionList;
      return &descriptionList;
    }

    typedef Measure* (*MeasureFactory)(const std::string);
    static std::map<std::string,MeasureFactory>* pFactoryList(void)
    {
      static std::map<std::string,MeasureFactory> factoryList;
      return &factoryList;
    }

  protected:
    Measure(const std::string uri){}
    ~Measure(void){}
    
  public:
    static void connect(const std::string name, const MeasureDescription cD, const MeasureFactory cF)
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

    static Measure* factory(const std::string name, const std::string uri)
    {
      Measure* obj=NULL;
      if(isConnected(name))
      {
        obj=(*pFactoryList())[name](uri);
      }
      else
      {
        throw("Measure is not connected to the requested component");
      }
      return(obj);
    }

    virtual std::vector<GraphEdge> findEdges(const Trajectory&,const uint32_t,const uint32_t) = 0;
    virtual double computeEdgeCost(const Trajectory&,const GraphEdge) = 0;
  };
}

#endif
