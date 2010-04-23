#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include <vector>

#include "GPSTime.h"
#include "Pose.h"
#include "TangentPose.h"

namespace tommas
{
  class Trajectory
  {
  public:
    virtual std::pair<GPSTime,GPSTime> domain(void) = 0;
    virtual std::vector<Pose> evaluate(const std::vector<GPSTime>&) = 0;
    virtual std::vector<TangentPose> tangent(const std::vector<GPSTime>&) = 0;
  };
}

#endif
