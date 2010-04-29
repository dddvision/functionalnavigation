#ifndef POSE_H
#define POSE_H

#include <math.h>

namespace tommas
{
  class Pose
  {
  public:
    double p[3]; // Position
    double q[4]; // Quaternion
    Pose(void)
    {
      p[0] = NAN;
      p[1] = NAN;
      p[2] = NAN;
      q[0] = NAN;
      q[1] = NAN;
      q[2] = NAN;
      q[3] = NAN;
    }
    Pose(const Pose& pose)
    {
      this->p[0]=pose.p[0];
      this->p[1]=pose.p[1];
      this->p[2]=pose.p[2];
      this->q[0]=pose.q[0];
      this->q[1]=pose.q[1];
      this->q[2]=pose.q[2];
      this->q[3]=pose.q[3];
    }
  };
}

#endif
