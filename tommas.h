#ifndef TOMMAS_H
#define TOMMAS_H

namespace tommas
{
  typedef unsigned int NodeIndex;
  typedef unsigned int BlockIndex;
  typedef unsigned int SensorID;
  typedef double Time;
  typedef double Cost;
  typedef double[3] Position;
  typedef double[3] PositionRate;
  typedef double[4] Quaternion;
  typedef double[4] QuaternionRate;
  typedef std::pair<Time,Time> TimeLimits;
  typedef std::pair<NodeIndex,NodeIndex> Edge;

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

  std::map<const std::string,DynamicModel*> dynamicModelList;
  std::map<const std::string,Measure*> measureList;
  std::map<const std::string,Optimizer*> optimizerList;
  std::map<const std::string,DataContainer*> DataContainerList;
}

#endif

