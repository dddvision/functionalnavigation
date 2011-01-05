#include <algorithm>
#include <cmath>
#include <string>

#include "mex.h"

#include "DynamicModel.h"

namespace BrownianPlanar
{
  class BrownianPlanar : public tom::DynamicModel
  {
  private:
    static const double rate;
    static const double initialPosition[3];
    static const double initialQuaternion[4];
    static const double normalizedMass;
    static const double normalizedRotationalMass;

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
    std::vector<double> xRate;
    std::vector<double> yRate;
    std::vector<double> aRate;

    tom::TimeInterval interval;
    uint32_t firstNewBlock;

    static double paramToForce(uint32_t p)
    {
      static const double sixthIntMax = 4294967295.0/6.0;
      return (static_cast<double>(p)/sixthIntMax-3.0);
    }

    void transformPose(tom::Pose& pose)
    {
      double i0 = initialQuaternion[0];
      double i1 = initialQuaternion[1];
      double i2 = initialQuaternion[2];
      double i3 = initialQuaternion[3];

      double q0 = pose.q[0];
      double q1 = pose.q[1];
      double q2 = pose.q[2];
      double q3 = pose.q[3];

      pose.p[0] += initialPosition[0];
      pose.p[1] += initialPosition[1];
      pose.p[2] += initialPosition[2];

      pose.q[0] = q0*i0-q1*i1-q2*i2-q3*i3;
      pose.q[1] = q1*i0+q0*i1-q3*i2+q2*i3;
      pose.q[2] = q2*i0+q3*i1+q0*i2-q1*i3;
      pose.q[3] = q3*i0-q2*i1+q1*i2+q0*i3;

      return;
    }

    void evaluateGeneral(const double k, tom::Pose& pose)
    {
      // position and velocity A=[1,tau;0,1] B=[0.5*tau*tau;tau]
      static const double tau = 1/rate;
      static const double c0 = (0.5*tau*tau)/normalizedMass;
      static const double c1 = (0.5*tau*tau)/normalizedRotationalMass;
      static const double c2 = tau/normalizedMass;
      static const double c3 = tau/normalizedRotationalMass;

      double ct0;
      double ct1;
      double halfAngle;
            
      double tRemain;
      uint32_t bBase;
      uint32_t b;

      bBase = static_cast<uint32_t>(ceil(k))-1;
      tRemain = (k-static_cast<double>(bBase))/rate;
      
      for(b = firstNewBlock; b<bBase; ++b)
      {
        x[b+1] = x[b]+tau*xRate[b]+c0*fx[b];
        y[b+1] = y[b]+tau*yRate[b]+c0*fy[b];
        a[b+1] = a[b]+tau*aRate[b]+c1*fa[b];
        xRate[b+1] = xRate[b]+c2*fx[b];
        yRate[b+1] = yRate[b]+c2*fy[b];
        aRate[b+1] = aRate[b]+c3*fa[b];
      }
      firstNewBlock = std::max(firstNewBlock, bBase);

      ct0 = 0.5*tRemain*tRemain;
      ct1 = ct0/normalizedRotationalMass;
      ct0 /= normalizedMass;
      
      halfAngle = 0.5*(a[bBase]+tRemain*aRate[bBase]+ct1*fa[bBase]);
      pose.p[0] = x[bBase]+tRemain*xRate[bBase]+ct0*fx[bBase];
      pose.p[1] = y[bBase]+tRemain*yRate[bBase]+ct0*fy[bBase];
      pose.p[2] = 0.0;
      pose.q[0] = cos(halfAngle);
      pose.q[1] = 0.0;
      pose.q[2] = 0.0;
      pose.q[3] = sin(halfAngle);
      
//       mexPrintf("\nfx.size() = %d", fx.size());
//       mexPrintf("\ntau = %0.16f", tau);
//       mexPrintf("\nc0 = %0.16f", c0);
//       mexPrintf("\nc1 = %0.16f", c1);
//       mexPrintf("\nc2 = %0.16f", c2);
//       mexPrintf("\nc3 = %0.16f", c3);
//       mexPrintf("\nct0 = %0.16f", ct0);
//       mexPrintf("\nct1 = %0.16f", ct1);
//       mexPrintf("\nbBase = %u", bBase);
//       mexPrintf("\nhalfAngle = %0.16f", halfAngle);
//       mexPrintf("\nk = %0.16f", k);
//       mexPrintf("\nx[bBase] = %0.16f", x[bBase]);
//       mexPrintf("\ntRemain = %0.16f", tRemain);
//       mexPrintf("\nxRate[bBase] = %0.16f", xRate[bBase]);
//       mexPrintf("\nfx[bBase] = %0.16f", fx[bBase]);
//       mexPrintf("\npose.p[0] = %0.16f", pose.p[0]);
//       mexPrintf("\npose.p[1] = %0.16f", pose.p[1]);
//       mexPrintf("\npose.p[2] = %0.16f", pose.p[2]);
//       mexPrintf("\npose.q[0] = %0.16f", pose.q[0]);
//       mexPrintf("\npose.q[1] = %0.16f", pose.q[1]);
//       mexPrintf("\npose.q[2] = %0.16f", pose.q[2]);
//       mexPrintf("\npose.q[3] = %0.16f", pose.q[3]);

      return;
    }

    void evaluateTangentPose(const double k, tom::TangentPose& tangentPose)
    {
      static const tom::TangentPose nullTangentPose;
      static tom::TangentPose tP;
      double K;
      double halfAngle;
      double ct2;
      double ct3;
      double tRemain;
      uint32_t bBase;

      K = static_cast<double>(px.size());
      
      if(k<0.0)
      {
        tangentPose = nullTangentPose;
      }
      else if(k==0.0)
      {
        tangentPose.p[0] = 0.0;
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
      else if(k>K)
      {
        evaluateTangentPose(K, tP);
        tRemain = (k-K)/rate;
        halfAngle = atan2(tP.q[3],tP.q[0])+0.5*tRemain*tP.s[2];
        tangentPose.p[0] = tP.p[0]+tP.r[0]*tRemain;
        tangentPose.p[1] = tP.p[1]+tP.r[1]*tRemain;
        tangentPose.p[2] = tP.p[2]+tP.r[2]*tRemain;
        tangentPose.q[0] = cos(halfAngle);
        tangentPose.q[1] = 0.0;
        tangentPose.q[2] = 0.0;
        tangentPose.q[3] = sin(halfAngle);
        tangentPose.r[0] = tP.r[0];
        tangentPose.r[1] = tP.r[1];
        tangentPose.r[2] = tP.r[2];
        tangentPose.s[0] = 0.0;
        tangentPose.s[1] = 0.0;
        tangentPose.s[2] = tP.s[2];
      }
      else
      {
        evaluateGeneral(k, tangentPose);
        
        bBase = static_cast<uint32_t>(ceil(k))-1;
        tRemain = (k-static_cast<double>(bBase))/rate;
        
        ct2 = tRemain;
        ct3 = ct2/normalizedRotationalMass;
        ct2 /= normalizedMass;

        tangentPose.r[0] = xRate[bBase]+ct2*fx[bBase];
        tangentPose.r[1] = yRate[bBase]+ct2*fy[bBase];
        tangentPose.r[2] = 0.0;
        tangentPose.s[0] = 0.0;
        tangentPose.s[1] = 0.0;
        tangentPose.s[2] = aRate[bBase]+ct3*fa[bBase];
      }
      transformPose(tangentPose);
      return;
    }

    void evaluatePose(const double k, tom::Pose& pose)
    {
      static const tom::Pose nullPose;
      static tom::TangentPose tP;
      double K;
      double halfAngle;
      tom::WorldTime dt;

      K = static_cast<double>(px.size());
      
      if(k<0.0)
      {
        pose = nullPose;
      }
      else if(k==0.0)
      {
        pose.p[0] = 0.0;
        pose.p[1] = 0.0;
        pose.p[2] = 0.0;
        pose.q[0] = 1.0;
        pose.q[1] = 0.0;
        pose.q[2] = 0.0;
        pose.q[3] = 0.0;
      }
      else if(k>K)
      {
        evaluateTangentPose(K, tP);
        dt = (k-K)/rate;
        halfAngle = atan2(tP.q[3],tP.q[0])+0.5*dt*tP.s[2];
        pose.p[0] = tP.p[0]+tP.r[0]*dt;
        pose.p[1] = tP.p[1]+tP.r[1]*dt;
        pose.p[2] = tP.p[2]+tP.r[2]*dt;
        pose.q[0] = cos(halfAngle);
        pose.q[1] = 0.0;
        pose.q[2] = 0.0;
        pose.q[3] = sin(halfAngle);
      }
      else
      {
        evaluateGeneral(k, pose);
      }
      transformPose(pose);
      return;
    }

  public:
    BrownianPlanar(const tom::WorldTime initialTime, const std::string uri) :
      tom::DynamicModel(initialTime, uri)
    {
      static const unsigned reserve = 1024;
      interval.first = initialTime;
      interval.second = initialTime;
      firstNewBlock = 0;

      // begin with no parameter blocks
      px.resize(0);
      py.resize(0);
      pa.resize(0);
      fx.resize(0);
      fy.resize(0);
      fa.resize(0);

      // begin at an initial resting state
      x.resize(1, 0.0);
      y.resize(1, 0.0);
      a.resize(1, 0.0);
      xRate.resize(1, 0.0);
      yRate.resize(1, 0.0);
      aRate.resize(1, 0.0);

      // reserve space for vector expansion
      px.reserve(reserve);
      py.reserve(reserve);
      pa.reserve(reserve);
      fx.reserve(reserve);
      fy.reserve(reserve);
      fa.reserve(reserve);
      x.reserve(reserve);
      y.reserve(reserve);
      a.reserve(reserve);
      xRate.reserve(reserve);
      yRate.reserve(reserve);
      aRate.reserve(reserve);
      return;
    }

    tom::TimeInterval domain(void)
    {
      return (interval);
    }

    void evaluate(const std::vector<tom::WorldTime>& time, std::vector<tom::Pose>& pose)
    {
      static double k;
      unsigned n;
      unsigned N;
      N = time.size();
      pose.resize(N);
      for(n = 0; n<N; ++n)
      {
        k = rate*(time[n]-interval.first);
        evaluatePose(k, pose[n]);
      }
      
      return;
    }

    void tangent(const std::vector<tom::WorldTime>& time, std::vector<tom::TangentPose>& tangentPose)
    {
      static double k;
      unsigned n;
      unsigned N;
      N = time.size();
      tangentPose.resize(N);
      for(n = 0; n<N; ++n)
      {
        k = rate*(time[n]-interval.first);
        evaluateTangentPose(k, tangentPose[n]);
      }
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
      return (3);
    }

    uint32_t numExtensionBlocks(void)
    {
      return (static_cast<uint32_t>(px.size()));
    }

    bool getInitialLogical(const uint32_t parameterIndex)
    {
      throw("BrownianPlanar: has no initial logical parameters");
      return (false);
    }

    uint32_t getInitialUint32(const uint32_t parameterIndex)
    {
      throw("BrownianPlanar: has no initial integer parameters");
      return (0);
    }

    bool getExtensionLogical(const uint32_t blockIndex, const uint32_t parameterIndex)
    {
      throw("BrownianPlanar: has no extension logical parameters");
      return (false);
    }

    uint32_t getExtensionUint32(const uint32_t blockIndex, const uint32_t parameterIndex)
    {
      if(blockIndex>=numExtensionBlocks())
      {
        throw("BrownianPlanar: extension integer block index is out of range");
      }
      switch(parameterIndex)
      {
        case 0:
          return (px[blockIndex]);
        case 1:
          return (py[blockIndex]);
        case 2:
          return (pa[blockIndex]);
        default:
          throw("BrownianPlanar: extension integer parameter index is out of range");
          return (0);
      }
    }

    void setInitialLogical(const uint32_t parameterIndex, const bool value)
    {
      throw("BrownianPlanar: has no initial logical parameters");
      return;
    }

    void setInitialUint32(const uint32_t parameterIndex, const uint32_t value)
    {
      throw("BrownianPlanar: has no initial integer parameters");
      return;
    }

    void setExtensionLogical(const uint32_t blockIndex, const uint32_t parameterIndex, const bool value)
    {
      throw("BrownianPlanar: has no extension logical parameters");
      return;
    }

    void setExtensionUint32(const uint32_t blockIndex, const uint32_t parameterIndex, const uint32_t value)
    {
      if(blockIndex>=numExtensionBlocks())
      {
        throw("BrownianPlanar: extension integer block index is out of range");
      }
      switch(parameterIndex)
      {
        case 0:
          px[blockIndex] = value;
          fx[blockIndex] = paramToForce(value);
          break;
        case 1:
          py[blockIndex] = value;
          fy[blockIndex] = paramToForce(value);
          break;
        case 2:
          pa[blockIndex] = value;
          fa[blockIndex] = paramToForce(value);
          break;
        default:
          throw("BrownianPlanar: extension integer parameter index is out of range");
      }
      firstNewBlock = std::min(firstNewBlock, blockIndex);
    }

    double computeInitialBlockCost(void)
    {
      return (0.0);
    }

    double computeExtensionBlockCost(const uint32_t blockIndex)
    {
      double f0, f1, f2;
      double cost;
      f0 = fx[blockIndex];
      f1 = fy[blockIndex];
      f2 = fa[blockIndex];
      cost = 0.5*(f0*f0+f1*f1+f2*f2);
      return (cost);
    }

    void extend(void)
    {
      static const uint32_t halfIntMax = floor(4294967295.0/2.0);
      static const double force = paramToForce(halfIntMax);
      unsigned oldSize = x.size();
      unsigned newSize = oldSize+1;
      px.resize(oldSize, halfIntMax);
      py.resize(oldSize, halfIntMax);
      pa.resize(oldSize, halfIntMax);
      fx.resize(oldSize, force);
      fy.resize(oldSize, force);
      fa.resize(oldSize, force);
      x.resize(newSize);
      y.resize(newSize);
      a.resize(newSize);
      xRate.resize(newSize);
      yRate.resize(newSize);
      aRate.resize(newSize);
      interval.second = interval.first+static_cast<double>(oldSize)/rate;
      return;
    }

    tom::DynamicModel* copy(void)
    {
      tom::WorldTime initialTime = this->interval.first;
      std::string uri = "";
      BrownianPlanar* obj = new BrownianPlanar(initialTime, uri);
            
      // parameters
      obj->px = this->px;
      obj->py = this->py;
      obj->pa = this->pa;

      // forces
      obj->fx = this->fx;
      obj->fy = this->fy;
      obj->fa = this->fa;

      // positions
      obj->x = this->x;
      obj->y = this->y;
      obj->a = this->a;

      // rates
      obj->xRate = this->xRate;
      obj->yRate = this->yRate;
      obj->aRate = this->aRate;

      obj->interval = this->interval;
      obj->firstNewBlock = this->firstNewBlock;
      
      return (obj);
    }

  private:
    static std::string componentDescription(void)
    {
      return ("Planar motion model of a rigid body with unit inertia that undergoes Brownian forcing.");
    }

    static tom::DynamicModel* componentFactory(const tom::WorldTime initialTime, const std::string uri)
    {
      return (new BrownianPlanar(initialTime, uri));
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
      BrownianPlanar::initialize("BrownianPlanar");
    }
  } _Initializer;
}

#include "BrownianPlanarConfig.cpp"
