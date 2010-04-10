#ifndef MEASURE_H
#define MEASURE_H

#include "tommas.h"

namespace tommas
{
  typedef std::pair<NodeIndex,NodeIndex> Edge;
  typedef std::vector<Edge> EdgeList;
  
  class Measure;
  typedef Measure* (*MeasureFactory)(std::string);
  extern std::map<std::string,MeasureFactory> measureList;
  
  class Measure : public Sensor
  {
  protected:
    Measure(const std::string uri){}
  
  public:
    virtual EdgeList findEdges(const NodeIndex,const NodeIndex) = 0;
    virtual Cost computeEdgeCost(const Trajectory&,const NodeIndex,const NodeIndex) = 0;
    
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
