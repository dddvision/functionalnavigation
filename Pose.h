#ifndef POSE_H
#define POSE_H

namespace tommas
{
  class Pose
  {
  public:
    double p[3]; // Position
    double q[4]; // Quaternion
  };
}

#endif
