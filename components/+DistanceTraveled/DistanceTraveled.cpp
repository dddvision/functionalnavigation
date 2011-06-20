#include <string>

#include "Measure.h"

namespace DistanceTraveled
{
  class DistanceTraveled : public tom::Measure
  {
  private:
    static const double dt;
    static const double deviation;

  public:
    DistanceTraveled(const tom::WorldTime initialTime, const std::string uri) : tom::Measure(initialTime, uri)
    {
      return;
    }

    void refresh(const Trajectory* x)
    {
      return;
    }
    
    bool hasData(void)
    {
      return (false);
    }
    
    unsigned first(void)
    {
      throw("The default sensor has no data.");
      return (0);
    }
    
    unsigned last(void)
    {
      throw("The default sensor has no data.");
      return (0);
    }
    
    WorldTime getTime(unsigned n)
    {
      throw("The default sensor has no data.");
      return (0);
    }

    void findEdges(const uint32_t naMin, const uint32_t naMax, const uint32_t nbMin, 
      const uint32_t nbMax, std::vector<GraphEdge>& edgeList)
    {
      edgeList.resize(0);
      return;
    }

    double computeEdgeCost(const Trajectory* x, const GraphEdge graphEdge)
    {
      return (0.0);
    }
            
  private:
    static std::string componentDescription(void)
    {
      return ("Creates a set of relative measures based on total distance traveled.");
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