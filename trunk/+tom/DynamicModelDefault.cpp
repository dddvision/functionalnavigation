#include "DynamicModel.h"
#include "WGS84.h"

namespace tom
{
  /** This default dynamic model represents a stationary body at the world origin with no input parameters. */
  class DynamicModelDefault : public virtual DynamicModel
  {
  protected:
    std::pair<double, double> interval; /**< stores the Trajectory domain */

  public:
    /** Constructor and parent class initializer of the same form. */
    DynamicModelDefault(const double initialTime, const std::string uri) :
      DynamicModel(initialTime, uri)
    {
      interval.first = initialTime;
      interval.second = INF;
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

    std::pair<double, double> domain(void)
    {
      return (interval);
    }

    void evaluate(const double& time, Pose& pose)
    {
      static const Pose nullPose;
      if(time<interval.first)
      {
        pose = nullPose;
      }
      else
      {
        pose.p[0] = WGS84::majorRadius;
        pose.p[1] = 0.0;
        pose.p[2] = 0.0;
        pose.q[0] = 1.0;
        pose.q[1] = 0.0;
        pose.q[2] = 0.0;
        pose.q[3] = 0.0;
      }
      return;
    }

    void tangent(const double& time, TangentPose& tangentPose)
    {
      static const TangentPose nullTangentPose;
      if(time<interval.first)
      {
        tangentPose = nullTangentPose;
      }
      else
      {
        tangentPose.p[0] = WGS84::majorRadius;
        tangentPose.p[1] = 0.0;
        tangentPose.p[2] = 0.0;
        tangentPose.q[0] = 1.0;
        tangentPose.q[1] = 0.0;
        tangentPose.q[2] = 0.0;
        tangentPose.q[3] = 0.0;
        tangentPose.r[0] = 0.0;
        tangentPose.r[1] = 0.0;
        tangentPose.r[2] = 0.0;
        tangentPose.s[0] = 0.0;
        tangentPose.s[1] = 0.0;
        tangentPose.s[2] = 0.0;
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
