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
  class Measure;
  typedef Measure* (*MeasureFactory)(const std::string);
  extern std::map<std::string,MeasureFactory> measureList;
  
  class Measure : public Sensor
  {
  private:
    Measure(const Measure&){}
    
  protected:
    Measure(const std::string uri){}
    ~Measure(void){}
  
  public:
    virtual std::vector<GraphEdge> findEdges(const Trajectory&,const unsigned,const unsigned) = 0;
    virtual double computeEdgeCost(const Trajectory&,const GraphEdge) = 0;
    
    static std::string frameworkClass(void) { return std::string("Measure"); }
    static Measure* factory(const std::string measureName, const std::string uri)
    {
      Measure* obj=NULL;
      if(measureList.find(measureName) != measureList.end())
      {
        obj=measureList[measureName](uri);
      }
      return obj;
    }
  };
}

#endif
