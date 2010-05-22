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
    unsigned firstNewBlock;
    
    static double paramToForce(uint32_t p)
    {
      static const double sixthIntMax=4294967295.0/6.0;
      return(static_cast<double>(p)/sixthIntMax-3.0);
    }
    
    void evaluateGeneral(const WorldTime& time, Pose& pose,
                         unsigned& dkFloor, double& dtRemain, double& halfAngle)
    {
      // position and velocity A=[1,tau;0,1] B=[tau+0.5*tau*tau;tau]
      static const double tau=1/rate;
      static const double c0=normalizedMass*(tau+0.5*tau*tau);
      static const double c1=normalizedRotationalMass*(tau+0.5*tau*tau);
      static const double c2=normalizedMass*tau;
      static const double c3=normalizedRotationalMass*tau;
      
      double dt;
      double ct0;
      double ct1;
      unsigned K;
      unsigned k;
      unsigned dk;
      unsigned dtFloor;
      
      dt=time-interval.first;
      dk=dt*rate;
      K=static_cast<unsigned>(ceil(dk));
      if(K>firstNewBlock)
      {
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
      }
      
      dkFloor=static_cast<unsigned>(floor(dk));
      dtFloor=static_cast<double>(dkFloor)/rate;
      dtRemain=dt-dtFloor;
      
      ct0=dtRemain+0.5*dtRemain*dtRemain;
      ct1=normalizedRotationalMass*ct0;
      ct0*=normalizedMass;
      
      pose.p[0]=x[dkFloor]+tau*xRate[dkFloor]+ct0*fx[dkFloor];
      pose.p[1]=y[dkFloor]+tau*yRate[dkFloor]+ct0*fy[dkFloor];
      pose.p[2]=0.0;
      halfAngle=0.5*(a[dkFloor]+tau*aRate[dkFloor]+ct1*fa[dkFloor]);
      pose.q[0]=cos(halfAngle);
      pose.q[1]=0.0;
      pose.q[2]=0.0;
      pose.q[3]=sin(halfAngle);
      
      return;
    }
    
    void evaluatePose(const WorldTime& time, Pose& pose)
    {
      static const Pose nullPose;
      unsigned dkFloor;
      double dtRemain;
      double halfAngle;
      
      if((time<interval.first)||(time>interval.second))
      {
        pose=nullPose;
        return;
      }
      
      evaluateGeneral(time,pose,dkFloor,dtRemain,halfAngle);
      
      return;
    }
    
    void evaluateTangentPose(const WorldTime& time, TangentPose& tangentPose)
    {
      static const TangentPose nullTangentPose;
      unsigned dkFloor;
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
      ct3=normalizedRotationalMass*ct2;
      ct2*=normalizedMass;
      
      tangentPose.r[0]=xRate[dkFloor]+ct2*fx[dkFloor];
      tangentPose.r[1]=yRate[dkFloor]+ct2*fy[dkFloor];
      tangentPose.r[2]=0.0;
      halfAngleRate=0.5*(aRate[dkFloor]+ct3*fa[dkFloor]);
      tangentPose.s[0]=-sin(halfAngle)*halfAngleRate;
      tangentPose.s[1]=0.0;
      tangentPose.s[2]=0.0;
      tangentPose.s[3]=cos(halfAngle)*halfAngleRate;
      
      return;
    }
    
  public:
    BrownianPlanar(const WorldTime initialTime,const std::string uri) : DynamicModel(initialTime, uri)
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
      xRate.reserve(reserve);
      yRate.reserve(reserve);
      aRate.reserve(reserve);
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
      throw("BrownianPlanar: has no initial logical parameters");
      return(false);
    }

    uint32_t getInitialUint32(unsigned parameterIndex)
    {
      throw("BrownianPlanar: has no initial integer parameters");
      return(0);
    }

    bool getExtensionLogical(unsigned blockIndex, unsigned parameterIndex)
    {
      throw("BrownianPlanar: has no extension logical parameters");
      return(false);
    }

    uint32_t getExtensionUint32(unsigned blockIndex, unsigned parameterIndex)
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

    void setInitialLogical(unsigned parameterIndex, bool value)
    {
      throw("BrownianPlanar: has no initial logical parameters");
      return;
    }

    void setInitialUint32(unsigned parameterIndex, uint32_t value)
    {
      throw("BrownianPlanar: has no initial integer parameters");
      return;
    }

    void setExtensionLogical(unsigned blockIndex, unsigned parameterIndex, bool value)
    {
      throw("BrownianPlanar: has no extension logical parameters");
      return;
    }

    void setExtensionUint32(unsigned blockIndex, unsigned parameterIndex, uint32_t value)
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

    double computeExtensionBlockCost(unsigned blockIndex)
    {
      double f0,f1,f2;
      double cost;
      f0=fx[blockIndex];
      f1=fy[blockIndex];
      f2=fa[blockIndex];
      cost=0.5*(f0*f0+f1*f1+f2*f2);
      return(cost);
    }

    void extend(unsigned num)
    {
      static const uint32_t halfIntMax=floor(4294967295.0/2.0);
      static const double force=paramToForce(halfIntMax);
      unsigned newSize=px.size()+num;
      px.resize(newSize,halfIntMax);
      py.resize(newSize,halfIntMax);
      pa.resize(newSize,halfIntMax);
      fx.resize(newSize,force);
      fy.resize(newSize,force);
      fa.resize(newSize,force);
      interval.second=interval.first+static_cast<double>(newSize)/rate;
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
  
  DynamicModel* BrownianPlanarFactory(const WorldTime initialTime,const std::string uri)
  { return(new BrownianPlanar(initialTime,uri)); }
}

#include "BrownianPlanarConfig.cpp"
