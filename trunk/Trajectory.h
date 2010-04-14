#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include "Time.h"
#include "Pose.h"
#include "TangentPose.h"

namespace tommas
{
  class Trajectory
  {
  public:
    virtual std::pair<Time,Time> domain(void) = 0;
    virtual std::vector<Pose> evaluate(const std::vector<Time>&) = 0;
    virtual std::vector<TangentPose> tangent(const std::vector<Time>&) = 0;
  };
}

#endif
