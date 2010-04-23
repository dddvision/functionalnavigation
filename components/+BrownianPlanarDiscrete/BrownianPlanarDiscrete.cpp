#include <algorithm>
#include <cmath>
#include <assert.h>

#include "DynamicModel.h"

namespace tommas
{
  class BrownianPlanarDiscrete : public DynamicModel
  {  
  private:
    static const double rate;
    static const double initialPosition[3];
    static const double initialQuaternion[4];
    
    // parameters
    std::vector<uint32_t> px;
    std::vector<uint32_t> py;
    std::vector<uint32_t> pa;
    
    // forces
    std::vector<double> fx;
    std::vector<double> fy;
    std::vector<double> fa;
    
    // positions
    std::vector<double> x;
    std::vector<double> y;
    std::vector<double> a;
    
    // rates
    std::vector<double> xd;
    std::vector<double> yd;
    std::vector<double> ad;
    
    TimeInterval interval;
    unsigned firstNewBlock;
    
    static double paramToForce(uint32_t p)
    {
      static const double sixthIntMax=4294967295.0/6.0;
      return(static_cast<double>(p)/sixthIntMax-3.0);
    }

  public:
    BrownianPlanarDiscrete(WorldTime initialTime, std::string uri) : DynamicModel(initialTime, uri)
    {
      const unsigned reserve=1024;
      px.reserve(reserve);
      py.reserve(reserve);
      pa.reserve(reserve);
      fx.reserve(reserve);
      fy.reserve(reserve);
      fa.reserve(reserve);
      x.reserve(reserve);
      y.reserve(reserve);
      a.reserve(reserve);
      xd.reserve(reserve);
      yd.reserve(reserve);
      ad.reserve(reserve);
      interval.first=initialTime;
      interval.second=initialTime;
      firstNewBlock=0;
      return;
    }

    WorldTime updateRate(void) const {return(rate);}
    unsigned numInitialLogical(void) const {return(0);}
    unsigned numInitialUint32(void) const {return(0);}
    unsigned numExtensionLogical(void) const {return(0);}
    unsigned numExtensionUint32(void) const {return(3);}

    unsigned numExtensionBlocks(void)
    {
      return(px.size());
    }

    bool getInitialLogical(unsigned parameterIndex)
    {
      assert(false);
      return(false);
    }

    uint32_t getInitialUint32(unsigned parameterIndex)
    {
      assert(false);
      return(0);
    }

    bool getExtensionLogical(unsigned blockIndex, unsigned parameterIndex)
    {
      assert(false);
      return(false);
    }

    uint32_t getExtensionUint32(unsigned blockIndex, unsigned parameterIndex)
    {
      assert(blockIndex<this->numExtensionBlocks());
      switch(parameterIndex)
      {
        case 0:
          return(px[blockIndex]);
        case 1:
          return(py[blockIndex]);
        case 2:
          return(pa[blockIndex]);
        default:
          assert(false);
          return(0);
      }
    }

    void setInitialLogical(unsigned parameterIndex, bool value)
    {
      assert(false);
      return;
    }

    void setInitialUint32(unsigned parameterIndex, uint32_t value)
    {
      assert(false);
      return;
    }

    void setExtensionLogical(unsigned blockIndex, unsigned parameterIndex, bool value)
    {
      assert(false);
      return;
    }

    void setExtensionUint32(unsigned blockIndex, unsigned parameterIndex, uint32_t value)
    {
      switch(parameterIndex)
      {
        case 0:
          px[blockIndex]=value;
          fx[blockIndex]=paramToForce(value);
          break;
        case 1:
          py[blockIndex]=value;
          fy[blockIndex]=paramToForce(value);
          break;
        case 2:
          pa[blockIndex]=value;
          fa[blockIndex]=paramToForce(value);
          break;
        default:
          assert(false);
      }
      firstNewBlock=std::min(firstNewBlock,blockIndex);
    }

    double computeInitialBlockCost(void) {return(0.0);}

    double computeExtensionBlockCost(unsigned blockIndex)
    {
      double force[3];
      double cost;
      force[0]=fx[blockIndex];
      force[1]=fy[blockIndex];
      force[2]=fa[blockIndex];
      cost=0.5*(force[0]*force[0]+force[1]*force[1]+force[2]*force[2]);
      return(cost);
    }

    void extend(unsigned num)
    {
      static const uint32_t paramDefault=floor(4294967295.0/2.0);
      static const double forceDefault=paramToForce(paramDefault);
      unsigned newSize=px.size()+num;
      px.resize(newSize,paramDefault);
      py.resize(newSize,paramDefault);
      pa.resize(newSize,paramDefault);
      fx.resize(newSize,forceDefault);
      fy.resize(newSize,forceDefault);
      fa.resize(newSize,forceDefault);
      interval.second=interval.first+static_cast<double>(newSize)/rate;
      return;
    }

    TimeInterval domain(void) {return(interval);}

    void evaluate(const std::vector<WorldTime>& time, std::vector<Pose>& pose)
    {
      return;    
    }

    void tangent(const std::vector<WorldTime>& pose, std::vector<TangentPose>& tangentPose)
    {
      return;
    }
  };
  
  DynamicModel* BrownianPlanarDiscreteFactory(WorldTime initialTime, std::string uri)
  { return(new BrownianPlanarDiscrete(initialTime,uri)); }
}

#include "BrownianPlanarDiscreteConfig.cpp"
