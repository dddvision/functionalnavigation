#ifndef MEASURE_H
#define MEASURE_H

#include <map>
#include <string>
#include <vector>
#include <iostream>

#include "Edge.h"
#include "Trajectory.h"
#include "Sensor.h"

namespace tommas
{ 
  class Measure;
  typedef Measure* (*MeasureFactory)(std::string);
  extern std::map<std::string,MeasureFactory> measureList;
  
  class Measure : public Sensor
  {
  protected:
    Measure(const std::string uri){}
  
  public:
    virtual std::vector<Edge> findEdges(const unsigned,const unsigned) = 0;
    virtual double computeEdgeCost(const Trajectory&,const Edge) = 0;
    
    static std::string frameworkClass(void) { return std::string("Measure"); }
    static Measure* factory(std::string measureName,std::string uri)
    {
      if(measureList.find(measureName) == measureList.end())
      { 
        std::cerr << measureName << " not found in measure list" << std::endl;
        return NULL;
      }
      else { return measureList[measureName](uri); }
    }
  };
}

#endif
