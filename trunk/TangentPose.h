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
    TangentPose(void)
    {
      r[0] = NAN;
      r[1] = NAN;
      r[2] = NAN;
      s[0] = NAN;
      s[1] = NAN;
      s[2] = NAN;
      s[3] = NAN;
    }
    TangentPose(TangentPose& tangentPose) : Pose(tangentPose)
    {
      this->r[0]=tangentPose.r[0];
      this->r[1]=tangentPose.r[1];
      this->r[2]=tangentPose.r[2];
      this->s[0]=tangentPose.s[0];
      this->s[1]=tangentPose.s[1];
      this->s[2]=tangentPose.s[2];
      this->s[3]=tangentPose.s[3];
    }
  };
}

#endif
