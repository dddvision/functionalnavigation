#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include "tommas.h"

namespace tommas
{
  typedef double Time;
  typedef std::pair<Time,Time> TimeInterval;
  typedef double Position[3];
  typedef double PositionRate[3];
  typedef double Quaternion[4];
  typedef double QuaternionRate[4];

  class Pose
  {
  public:
    Position p;
    Quaternion q;
  };

  class PoseRate
  {
  public:
    PositionRate r;
    QuaternionRate s;
  };
  
  class TangentPose : public Pose : public PoseRate {};

  class Trajectory
  { 
  public:
    virtual TimeInterval domain(void) = 0;
    virtual std::vector<Pose> evaluate(const std::vector<Time>&) = 0;
    virtual std::vector<TangentPose> evaluate(const std::vector<Time>&) = 0;
  };
}

#endif
