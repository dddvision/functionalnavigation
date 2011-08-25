#include <string>
#include <cmath>
#include "Measure.h"

namespace DistanceTraveled
{
  class DistanceTraveled : public tom::Measure
  {
  private:
    static const double dt;
    static const double deviation;
    tom::WorldTime tMin;
    tom::WorldTime tMax;

  public:
    DistanceTraveled(const tom::WorldTime initialTime, const std::string uri) :
      tom::Measure(initialTime, uri)
    {
      tMin = initialTime;
      tMax = initialTime;
      return;
    }

    void refresh(tom::Trajectory* x)
    {
      tom::TimeInterval interval;
      interval = x->domain();
      if(interval.second>tMax)
      {
        tMax = interval.second;
      }
      return;
    }

    uint32_t first(void)
    {
      return (0);
    }

    uint32_t last(void)
    {
      return static_cast<uint32_t>(floor((tMax-tMin)/dt));
    }

    bool hasData(void)
    {
      return (this->last()>this->first());
    }

    tom::WorldTime getTime(uint32_t n)
    {
      return (tMin+dt*static_cast<double>(n));
    }

    void findEdges(const uint32_t naMin, const uint32_t naMax, const uint32_t nbMin, const uint32_t nbMax, std::vector<
        tom::GraphEdge>& edgeList)
    {
      unsigned K = this->last();
      unsigned k;

      edgeList.reserve(K);
      edgeList.resize(K);
      for(k = 0; k<K; ++k)
      {
        edgeList[k].first = static_cast<uint32_t>(k);
        edgeList[k].second = static_cast<uint32_t>(k+1);
      }
      return;
    }

    double computeEdgeCost(tom::Trajectory* x, const tom::GraphEdge graphEdge)
    {
      static std::vector<tom::WorldTime> tA(1);
      static std::vector<tom::WorldTime> tB(1);
      static std::vector<tom::Pose> poseA(1);
      static std::vector<tom::Pose> poseB(1);
      double y[3];

      tA[0] = this->getTime(graphEdge.first);
      tB[0] = this->getTime(graphEdge.second);
      x->evaluate(tA, poseA);
      x->evaluate(tB, poseB);

      y[0] = poseB[0].p[0]-poseA[0].p[0];
      y[1] = poseB[0].p[1]-poseA[0].p[1];
      y[2] = poseB[0].p[2]-poseA[0].p[2];

      return (0.5*(y[0]*y[0]+y[1]*y[1]+y[2]*y[2])/(deviation*deviation));
    }

  private:
    static std::string componentDescription(void)
    {
      return ("Creates a set of relative measures at equal time intervals based on total distance traveled.");
    }

    static tom::Measure* componentFactory(const tom::WorldTime initialTime, const std::string uri)
    {
      return (new DistanceTraveled(initialTime, uri));
    }

  protected:
    static void initialize(std::string name)
    {
      connect(name, componentDescription, componentFactory);
    }
    friend class Initializer;
  };

  class Initializer
  {
  public:
    Initializer(void)
    {
      DistanceTraveled::initialize("DistanceTraveled");
    }
  } _Initializer;
}

#include "DistanceTraveledConfig.cpp"
