#include <algorithm>
#include <cmath>

#include "DynamicModel.h"

namespace tommas
{
  class BrownianPlanar : public DynamicModel
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
    
    TimeInterval interval;
    uint32_t firstNewBlock;
    
    static double paramToForce(uint32_t p)
    {
      static const double sixthIntMax=4294967295.0/6.0;
      return(static_cast<double>(p)/sixthIntMax-3.0);
    }
    
    void transformPose(Pose& pose)
    {
      double i0=initialQuaternion[0];
      double i1=initialQuaternion[1];
      double i2=initialQuaternion[2];
      double i3=initialQuaternion[3];
      
      double q0=pose.q[0];
      double q1=pose.q[1];
      double q2=pose.q[2];
      double q3=pose.q[3];
      
      pose.p[0]+=initialPosition[0];
      pose.p[1]+=initialPosition[1];
      pose.p[2]+=initialPosition[2];
    
      pose.q[0]=q0*i0-q1*i1-q2*i2-q3*i3;
      pose.q[1]=q1*i0+q0*i1-q3*i2+q2*i3;
      pose.q[2]=q2*i0+q3*i1+q0*i2-q1*i3;
      pose.q[3]=q3*i0-q2*i1+q1*i2+q0*i3;
      
      return;
    }
    
    void transformTangentPose(TangentPose& tangentPose)
    {
      double i0=initialQuaternion[0];
      double i1=initialQuaternion[1];
      double i2=initialQuaternion[2];
      double i3=initialQuaternion[3];
      
      double s0=tangentPose.s[0];
      double s1=tangentPose.s[1];
      double s2=tangentPose.s[2];
      double s3=tangentPose.s[3];
      
      transformPose(tangentPose);
      tangentPose.s[0]=s0*i0-s1*i1-s2*i2-s3*i3;
      tangentPose.s[1]=s1*i0+s0*i1-s3*i2+s2*i3;
      tangentPose.s[2]=s2*i0+s3*i1+s0*i2-s1*i3;
      tangentPose.s[3]=s3*i0-s2*i1+s1*i2+s0*i3;
      
      return;
    }
    
    void evaluateGeneral(const WorldTime& time, Pose& pose,
                         uint32_t& dkFloor, double& dtRemain, double& halfAngle)
    {
      // position and velocity A=[1,tau;0,1] B=[0.5*tau*tau;tau]
      static const double tau=1/rate;
      static const double c0=(0.5*tau*tau)/normalizedMass;
      static const double c1=(0.5*tau*tau)/normalizedRotationalMass;
      static const double c2=tau/normalizedMass;
      static const double c3=tau/normalizedRotationalMass;
      
      double dt;
      double ct0;
      double ct1;
      double dk;
      double dtFloor;
      uint32_t K;
      uint32_t k;
      
      dt=time-interval.first;
      dk=dt*rate;
      K=static_cast<uint32_t>(ceil(dk));
      for( k=firstNewBlock; k<K; ++k )
      {
        x[k+1]=x[k]+tau*xRate[k]+c0*fx[k];
        y[k+1]=y[k]+tau*yRate[k]+c0*fy[k];
        a[k+1]=a[k]+tau*aRate[k]+c1*fa[k];
        xRate[k+1]=xRate[k]+c2*fx[k];
        yRate[k+1]=yRate[k]+c2*fy[k];
        aRate[k+1]=aRate[k]+c3*fa[k];
      }
      firstNewBlock=K;
      
      dkFloor=static_cast<uint32_t>(floor(dk));    
      dtFloor=static_cast<double>(dkFloor)/rate;
      dtRemain=dt-dtFloor;
      
      ct0=0.5*dtRemain*dtRemain;
      ct1=ct0/normalizedRotationalMass;
      ct0/=normalizedMass;
      
      pose.p[0]=x[dkFloor]+dtRemain*xRate[dkFloor]+ct0*fx[dkFloor];
      pose.p[1]=y[dkFloor]+dtRemain*yRate[dkFloor]+ct0*fy[dkFloor];
      pose.p[2]=0.0;
      halfAngle=0.5*(a[dkFloor]+dtRemain*aRate[dkFloor]+ct1*fa[dkFloor]);
      pose.q[0]=cos(halfAngle);
      pose.q[1]=0.0;
      pose.q[2]=0.0;
      pose.q[3]=sin(halfAngle);
      
      return;
    }
    
    void evaluatePose(const WorldTime& time, Pose& pose)
    {
      static const Pose nullPose;
      uint32_t dkFloor;
      double dtRemain;
      double halfAngle;
      
      if((time<interval.first)||(time>interval.second))
      {
        pose=nullPose;
        return;
      }
      
      evaluateGeneral(time,pose,dkFloor,dtRemain,halfAngle);
      transformPose(pose);
      
      return;
    }
    
    void evaluateTangentPose(const WorldTime& time, TangentPose& tangentPose)
    {
      static const TangentPose nullTangentPose;
      uint32_t dkFloor;
      double dtRemain;
      double halfAngle;
      double halfAngleRate;
      double ct2;
      double ct3;
      
      if((time<interval.first)||(time>interval.second))
      {
        tangentPose=nullTangentPose;
        return;
      }
      
      evaluateGeneral(time,tangentPose,dkFloor,dtRemain,halfAngle);
      
      ct2=dtRemain;
      ct3=ct2/normalizedRotationalMass;
      ct2/=normalizedMass;
      
      tangentPose.r[0]=xRate[dkFloor]+ct2*fx[dkFloor];
      tangentPose.r[1]=yRate[dkFloor]+ct2*fy[dkFloor];
      tangentPose.r[2]=0.0;
      halfAngleRate=0.5*(aRate[dkFloor]+ct3*fa[dkFloor]);
      tangentPose.s[0]=-sin(halfAngle)*halfAngleRate;
      tangentPose.s[1]=0.0;
      tangentPose.s[2]=0.0;
      tangentPose.s[3]=cos(halfAngle)*halfAngleRate;
      
      transformTangentPose(tangentPose);
      
      return;
    }
    
  public:
    BrownianPlanar(const WorldTime initialTime,const std::string uri) : DynamicModel(initialTime, uri)
    {
      const unsigned reserve=1024;
      interval.first=initialTime;
      interval.second=initialTime;
      firstNewBlock=0;
      
      // begin with no parameter blocks
      px.resize(0);
      py.resize(0);
      pa.resize(0);
      fx.resize(0);
      fy.resize(0);
      fa.resize(0);

      // begin at an initial resting state
      x.resize(1,0.0);
      y.resize(1,0.0);
      a.resize(1,0.0);
      xRate.resize(1,0.0);
      yRate.resize(1,0.0);
      aRate.resize(1,0.0);

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

    uint32_t numInitialLogical(void) const {return(0);}
    uint32_t numInitialUint32(void) const {return(0);}
    uint32_t numExtensionLogical(void) const {return(0);}
    uint32_t numExtensionUint32(void) const {return(3);}

    uint32_t numExtensionBlocks(void)
    {
      return(static_cast<uint32_t>(px.size()));
    }

    bool getInitialLogical(uint32_t parameterIndex)
    {
      throw("BrownianPlanar: has no initial logical parameters");
      return(false);
    }

    uint32_t getInitialUint32(uint32_t parameterIndex)
    {
      throw("BrownianPlanar: has no initial integer parameters");
      return(0);
    }

    bool getExtensionLogical(uint32_t blockIndex, uint32_t parameterIndex)
    {
      throw("BrownianPlanar: has no extension logical parameters");
      return(false);
    }

    uint32_t getExtensionUint32(uint32_t blockIndex, uint32_t parameterIndex)
    {
      if(blockIndex>=numExtensionBlocks())
      {
        throw("BrownianPlanar: extension integer block index is out of range");
      }
      switch(parameterIndex)
      {
        case 0:
          return(px[blockIndex]);
        case 1:
          return(py[blockIndex]);
        case 2:
          return(pa[blockIndex]);
        default:
          throw("BrownianPlanar: extension integer parameter index is out of range");
          return(0);
      }
    }

    void setInitialLogical(uint32_t parameterIndex, bool value)
    {
      throw("BrownianPlanar: has no initial logical parameters");
      return;
    }

    void setInitialUint32(uint32_t parameterIndex, uint32_t value)
    {
      throw("BrownianPlanar: has no initial integer parameters");
      return;
    }

    void setExtensionLogical(uint32_t blockIndex, uint32_t parameterIndex, bool value)
    {
      throw("BrownianPlanar: has no extension logical parameters");
      return;
    }

    void setExtensionUint32(uint32_t blockIndex, uint32_t parameterIndex, uint32_t value)
    {
      if(blockIndex>=numExtensionBlocks())
      {
        throw("BrownianPlanar: extension integer block index is out of range");
      }
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
          throw("BrownianPlanar: extension integer parameter index is out of range");
      }
      firstNewBlock=std::min(firstNewBlock,blockIndex);
    }

    double computeInitialBlockCost(void) {return(0.0);}

    double computeExtensionBlockCost(uint32_t blockIndex)
    {
      double f0,f1,f2;
      double cost;
      f0=fx[blockIndex];
      f1=fy[blockIndex];
      f2=fa[blockIndex];
      cost=0.5*(f0*f0+f1*f1+f2*f2);
      return(cost);
    }

    void extend(void)
    {
      static const uint32_t halfIntMax=floor(4294967295.0/2.0);
      static const double force=paramToForce(halfIntMax);
      unsigned oldSize=x.size();
      unsigned newSize=oldSize+1;
      px.resize(oldSize,halfIntMax);
      py.resize(oldSize,halfIntMax);
      pa.resize(oldSize,halfIntMax);
      fx.resize(oldSize,force);
      fy.resize(oldSize,force);
      fa.resize(oldSize,force);
      x.resize(newSize);
      y.resize(newSize);
      a.resize(newSize);
      xRate.resize(newSize);
      yRate.resize(newSize);
      aRate.resize(newSize);      
      interval.second=interval.first+static_cast<double>(oldSize)/rate;
      return;
    }

    TimeInterval domain(void) { return(interval); }

    void evaluate(const std::vector<WorldTime>& time, std::vector<Pose>& pose)
    {
      unsigned k;
      unsigned K=time.size();
      pose.resize(K);
      for( k=0; k<K; ++k)
      {
        evaluatePose(time[k],pose[k]);
      }
      return;    
    }

    void tangent(const std::vector<WorldTime>& time, std::vector<TangentPose>& tangentPose)
    {
      unsigned k;
      unsigned K=time.size();
      tangentPose.resize(K);
      for( k=0; k<K; ++k)
      {
        evaluateTangentPose(time[k],tangentPose[k]);
      }
      return;   
    }
  };
  
  class BrownianPlanarInitializer
  {
  public:
    static DynamicModel* factory(const WorldTime initialTime, const std::string uri)
    { return(new BrownianPlanar(initialTime, uri)); }
    
    BrownianPlanarInitializer(void)
    {
      DynamicModel::associate("BrownianPlanar", "Description of BrownianPlanar", factory);
    }
  } _BrownianPlanarInitializer;

}

#include "BrownianPlanarConfig.cpp"
