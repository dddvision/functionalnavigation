#ifndef MEASURE_H
#define MEASURE_H

#include "tommas.h"
#include "Trajectory.h"

namespace tommas
{
  class Measure : public Sensor
  {
  public:
    static const std::string frameworkClass="Measure";
    static Measure* factory(const std::string measureName,const std::string uri)
      { return measureList[measureName](uri); }

  protected:
    Measure(std::string);
  
  public:
    virtual std::vector<Edge> findEdges(const NodeIndex,const NodeIndex);
    virtual Cost computeEdgeCost(const Trajectory*,const NodeIndex,const NodeIndex);
  };
}

#endif

