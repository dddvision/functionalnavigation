#ifndef TRAJECTORY_H
#define TRAJECTORY_H

#include "tommas.h"

namespace tommas
{
  typedef double Time;
  typedef std::pair<Time,Time> TimeLimits;
  typedef double Position[3];
  typedef double PositionRate[3];
  typedef double Quaternion[4];
  typedef double QuaternionRate[4];

  struct Pose
  {
    Position p;
    Quaternion q;
  };

  struct PoseRate
  {
    PositionRate p;
    QuaternionRate q;
  };

  class Trajectory
  { 
  public:
    virtual TimeLimits domain(void) = 0;
    virtual void evaluate(const std::vector<double>,std::vector<Pose>*) = 0;
    virtual void evaluate(const std::vector<double>,std::vector<Pose>*,std::vector<PoseRate>*) = 0;
  };
}

#endif

