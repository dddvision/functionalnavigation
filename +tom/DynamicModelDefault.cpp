#include "DynamicModel.h"

namespace tom
{
  /** This default dynamic model represents a stationary body at the world origin with no input parameters. */
  class DynamicModelDefault : virtual public DynamicModel
  {
  protected:
    hidi::TimeInterval interval; /**< stores the Trajectory domain */

  public:
    /** Constructor and parent class initializer of the same form. */
    DynamicModelDefault(const double initialTime, const std::string uri) :
      DynamicModel(initialTime, uri)
    {
      interval.first = initialTime;
      interval.second = INFINITY;
      return;
    }

    uint32_t numInitial(void)
    {
      return (0);
    }

    uint32_t numExtension(void)
    {
      return (0);
    }

    uint32_t numBlocks(void)
    {
      return (0);
    }

    uint32_t getInitial(uint32_t parameterIndex)
    {
      throw("The default dynamic model has no input parameters");
      return (0);
    }

    uint32_t getExtension(uint32_t blockIndex, uint32_t parameterIndex)
    {
      throw("The default dynamic model has no input parameters");
      return (0);
    }

    void setInitial(uint32_t parameterIndex, uint32_t value)
    {
      throw("The default dynamic model has no input parameters");
      return;
    }

    void setExtension(uint32_t blockIndex, uint32_t parameterIndex, uint32_t value)
    {
      throw("The default dynamic model has no input parameters");
      return;
    }

    double computeInitialCost(void)
    {
      return (0.0);
    }

    double computeExtensionCost(uint32_t blockIndex)
    {
      throw("The default dynamic model has no extension blocks.");
      return (0.0);
    }

    TimeInterval domain(void)
    {
      return (interval);
    }

    void evaluate(const std::vector<double>& time, std::vector<Pose>& pose)
    {
      static const Pose nullPose;
      unsigned n;
      unsigned N = time.size();
      pose.resize(N);
      for(n = 0; n<N; ++n)
      {
        if(time[n]<interval.first)
        {
          pose[n] = nullPose;
        }
        else
        {
          pose[n].p[0] = 6378137.0;
          pose[n].p[1] = 0.0;
          pose[n].p[2] = 0.0;
          pose[n].q[0] = 1.0;
          pose[n].q[1] = 0.0;
          pose[n].q[2] = 0.0;
          pose[n].q[3] = 0.0;
        }
      }
      return;
    }

    void tangent(const std::vector<double>& time, std::vector<TangentPose>& tangentPose)
    {
      static const TangentPose nullTangentPose;
      unsigned n;
      unsigned N = time.size();
      tangentPose.resize(N);
      for(n = 0; n<N; ++n)
      {
        if(time[n]<interval.first)
        {
          tangentPose[n] = nullTangentPose;
        }
        else
        {
          tangentPose[n].p[0] = 6378137.0;
          tangentPose[n].p[1] = 0.0;
          tangentPose[n].p[2] = 0.0;
          tangentPose[n].q[0] = 1.0;
          tangentPose[n].q[1] = 0.0;
          tangentPose[n].q[2] = 0.0;
          tangentPose[n].q[3] = 0.0;
          tangentPose[n].r[0] = 0.0;
          tangentPose[n].r[1] = 0.0;
          tangentPose[n].r[2] = 0.0;
          tangentPose[n].s[0] = 0.0;
          tangentPose[n].s[1] = 0.0;
          tangentPose[n].s[2] = 0.0;
        }
      }
      return;
    }

    void extend(void)
    {
      return;
    }

    tom::DynamicModel* copy(void)
    {
      double initialTime = this->interval.first;
      std::string uri = "";
      BrownianPlanar* obj = new BrownianPlanar(initialTime, uri);
      obj->interval = this->interval;
      return (obj);
    }

  private:
    static std::string componentDescription(void)
    {
      return ("This default dynamic model represents a stationary body at the world origin with no input parameters.");
    }

    static DynamicModel* componentFactory(const double initialTime, const std::string uri)
    {
      return (new DynamicModelDefault(initialTime, uri));
    }

  protected:
    static void initialize(std::string name)
    {
      connect(name, componentDescription, componentFactory);
    }
    friend class DynamicModelDefaultInitializer;
  };

  /** This class initializes DynamicModelDefault before the execution of main(). */
  class DynamicModelDefaultInitializer
  {
  public:
    DynamicModelDefaultInitializer(void)
    {
      DynamicModelDefault::initialize("tom");
    }
  } _DynamicModelDefaultInitializer;
}
