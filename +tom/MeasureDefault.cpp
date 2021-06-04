// Copyright 2011 Scientific Systems Company Inc., New BSD License
#include "Measure.h"

namespace tom
{
  /** This is the default measure. It has no data and constructs no graph edges. */
  class MeasureDefault : public virtual Measure
  {
  public:
    /** Constructor and parent class initializer of the same form. */
    MeasureDefault(const double initialTime, const std::string uri) :
      Measure(initialTime, uri)
    {
      return;
    }

    void refresh(Trajectory* x)
    {
      return;
    }

    bool hasData(void)
    {
      return (false);
    }

    uint32_t first(void)
    {
      throw("The default sensor has no data.");
      return (0);
    }

    uint32_t last(void)
    {
      throw("The default sensor has no data.");
      return (0);
    }

    double getTime(const uint32_t& n)
    {
      throw("The default sensor has no data.");
      return (0);
    }

    void findEdges(const uint32_t naMin, const uint32_t naMax, const uint32_t nbMin, const uint32_t nbMax, std::vector<
        GraphEdge>& edgeList)
    {
      edgeList.resize(0);
      return;
    }

    double computeEdgeCost(Trajectory* x, const GraphEdge graphEdge)
    {
      return (0.0);
    }

  private:
    static std::string componentDescription(void)
    {
      return ("This is the default measure. It has no data and constructs no graph edges.");
    }

    static Measure* componentFactory(const double initialTime, const std::string uri)
    {
      return (new MeasureDefault(initialTime, uri));
    }

  protected:
    static void initialize(std::string name)
    {
      connect(name, componentDescription, componentFactory);
    }
    friend class MeasureDefaultInitializer;
  };

  /** This class initializes MeasureDefault before the execution of main(). */
  class MeasureDefaultInitializer
  {
  public:
    MeasureDefaultInitializer(void)
    {
      MeasureDefault::initialize("tom");
    }
  } _MeasureDefaultInitializer;
}

