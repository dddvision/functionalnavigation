#include "DynamicModel.h"

namespace tom
{
  class DynamicModelDefault : public DynamicModel
  {
  protected:
    tom::TimeInterval interval;

  public:
    DynamicModelDefault(const WorldTime initialTime, const std::string uri) : DynamicModel(initialTime, uri)
    {
      interval.first = initialTime;
      interval.second = INFINITY;
      return;
    }

    uint32_t numInitialLogical(void) const
    {
      return (0);
    }

    uint32_t numInitialUint32(void) const
    {
      return (0);
    }

    uint32_t numExtensionLogical(void) const
    {
      return (0);
    }

    uint32_t numExtensionUint32(void) const
    {
      return (0);
    }

    uint32_t numExtensionBlocks(void)
    {
      return (0);
    }

    bool getInitialLogical(uint32_t parameterIndex)
    {
      throw("The default dynamic model has no input parameters");
      return (false);
    }

    uint32_t getInitialUint32(uint32_t parameterIndex)
    {
      throw("The default dynamic model has no input parameters");
      return (0);
    }

    bool getExtensionLogical(uint32_t blockIndex, uint32_t parameterIndex)
    {
      throw("The default dynamic model has no input parameters");
      return (false);
    }

    uint32_t getExtensionUint32(uint32_t blockIndex, uint32_t parameterIndex)
    {
      throw("The default dynamic model has no input parameters");
      return (0);
    }

    void setInitialLogical(uint32_t parameterIndex, bool value)
    {
      throw("The default dynamic model has no input parameters");
      return;
    }

    void setInitialUint32(uint32_t parameterIndex, uint32_t value)
    {
      throw("The default dynamic model has no input parameters");
      return;
    }

    void setExtensionLogical(uint32_t blockIndex, uint32_t parameterIndex, bool value)
    {
      throw("The default dynamic model has no input parameters");
      return;
    }

    void setExtensionUint32(uint32_t blockIndex, uint32_t parameterIndex, uint32_t value)
    {
      throw("The default dynamic model has no input parameters");
      return;
    }

    double computeInitialBlockCost(void)
    {
      return (0.0);
    }

    double computeExtensionBlockCost(uint32_t blockIndex)
    {
      throw("The default dynamic model has no extension blocks.");
      return (0.0);
    }

    TimeInterval domain(void)
    {
      return (interval);
    }

    void evaluate(const std::vector<WorldTime>& time, std::vector<Pose>& pose)
    {
      static const Pose nullPose;
      unsigned k;
      unsigned K = time.size();
      pose.resize(K);
      for(k = 0; k<K; ++k)
      {
        if(time[k]<interval.first)
        {
          pose[k] = nullPose;
        }
        else
        {
          pose[k].p[0] = 6378137.0;
          pose[k].p[1] = 0.0;
          pose[k].p[2] = 0.0;
          pose[k].q[0] = 1.0;
          pose[k].q[1] = 0.0;
          pose[k].q[2] = 0.0;
          pose[k].q[3] = 0.0;
        }
      }
      return;
    }

    void tangent(const std::vector<WorldTime>& time, std::vector<TangentPose>& tangentPose)
    {
      static const TangentPose nullTangentPose;
      unsigned k;
      unsigned K = time.size();
      tangentPose.resize(K);
      for(k = 0; k<K; ++k)
      {
        if(time[k]<interval.first)
        {
          tangentPose[k] = nullTangentPose;
        }
        else
        {
          tangentPose[k].p[0] = 6378137.0;
          tangentPose[k].p[1] = 0.0;
          tangentPose[k].p[2] = 0.0;
          tangentPose[k].q[0] = 1.0;
          tangentPose[k].q[1] = 0.0;
          tangentPose[k].q[2] = 0.0;
          tangentPose[k].q[3] = 0.0;
          tangentPose[k].r[0] = 0.0;
          tangentPose[k].r[1] = 0.0;
          tangentPose[k].r[2] = 0.0;
          tangentPose[k].s[0] = 0.0;
          tangentPose[k].s[1] = 0.0;
          tangentPose[k].s[2] = 0.0;
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
      tom::WorldTime initialTime = this->interval.first;
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

    static DynamicModel* componentFactory(const WorldTime initialTime, const std::string uri)
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

  class DynamicModelDefaultInitializer
  {
  public:
    DynamicModelDefaultInitializer(void)
    {
      DynamicModelDefault::initialize("tom");
    }
  } _DynamicModelDefaultInitializer;
}
