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
    virtual std::pair<WorldTime,WorldTime> domain(void) = 0;
    virtual std::vector<Pose> evaluate(const std::vector<WorldTime>&) = 0;
    virtual std::vector<TangentPose> tangent(const std::vector<WorldTime>&) = 0;
  };
}

#endif
