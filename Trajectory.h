#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include <vector>

#include "WorldTime.h"
#include "Pose.h"
#include "TangentPose.h"

namespace tommas
{
  class Trajectory
  {
  public:
    virtual TimeInterval domain(void) = 0;
    virtual void evaluate(const std::vector<WorldTime>&,std::vector<Pose>&) = 0;
    virtual void tangent(const std::vector<WorldTime>&,std::vector<TangentPose>&) = 0;
  };
}

#endif
