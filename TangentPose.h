#ifndef TANGENTPOSE_H
#define TANGENTPOSE_H

#include "Pose.h"

namespace tommas
{
  class TangentPose : public Pose
  {
  public:
    double r[3]; // PositionRate
    double s[4]; // QuaternionRate
  };
}

#endif
