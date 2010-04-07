#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include "tommas.h"

namespace tommas
{
  class Trajectory
  { 
  public:
    virtual TimeLimits domain(void);
    virtual void evaluate(const std::vector<double>,std::vector<Pose>*);
    virtual void evaluate(const std::vector<double>,std::vector<Pose>*,std::vector<PoseRate>*);
  };
}

#endif

