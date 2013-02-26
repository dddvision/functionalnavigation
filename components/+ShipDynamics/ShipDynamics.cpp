#include <algorithm>
#include <cmath>
#include <string>
#include <cstdio>

#include "DynamicModel.h"
#include "Rotation.h"
#include "WGS84.h"

namespace ShipDynamics
{
  class ShipDynamics : public tom::DynamicModel
  {
  private:
    // constant parameters
    static const double rate;
    static const double radius;
    static const double normalizedMass;
    static const double damping;
    static const double rotationalDamping;

    // initial frame
    double initialLongitude;
    double initialLatitude;
    double initialHeading;
    double initialPosition[3];
    double initialQuaternion[4];
    
    // dynamic parameters
    std::vector<uint32_t> pL;
    std::vector<uint32_t> pR;

    // forces
    std::vector<double> fL;
    std::vector<double> fR;
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

    hidi::TimeInterval interval;
    uint32_t firstNewBlock;

    void convertForces(const double L, const double R, const double heading, 
      const double NRate, const double ERate, const double CWRate,
      double &N, double &E, double &CW)
    {
      N = (L+R)*cos(heading)-damping*NRate*fabs(NRate);
      E = (L+R)*sin(heading)-damping*ERate*fabs(ERate);
      CW = (L-R)*radius-rotationalDamping*CWRate*fabs(CWRate); // assumed rotational damping
      return;
    }
    
    double paramToForce(const uint32_t p)
    {
      static const double halfIntMax = 4294967295.0/2.0;
      return (static_cast<double>(p)/halfIntMax-1.0);
    }
   
    void transformPose(tom::Pose& pose)
    {   
      double i0 = initialQuaternion[0];
      double i1 = initialQuaternion[1];
      double i2 = initialQuaternion[2];
      double i3 = initialQuaternion[3];
      double i00 = i0*i0;
      double i11 = i1*i1;
      double i22 = i2*i2;
      double i33 = i3*i3;
      double i01 = i0*i1;
      double i12 = i1*i2;
      double i23 = i2*i3;
      double i03 = i0*i3;
      double i02 = i0*i2;
      double i13 = i1*i3;
      
      double p0 = pose.p[0];
      double p1 = pose.p[1];
      double p2 = pose.p[2];
      double b0 = pose.q[0];
      double b1 = pose.q[1];
      double b2 = pose.q[2];
      double b3 = pose.q[3];
      
      std::vector<double> m(9, 0.0);
      
      m[0] = i00+i11-i22-i33;
      m[1] = 2.0*(i12+i03);
      m[2] = 2.0*(i13-i02);
      m[3] = 2.0*(i12-i03);
      m[4] = i00-i11+i22-i33;
      m[5] = 2.0*(i23+i01);
      m[6] = 2.0*(i13+i02);
      m[7] = 2.0*(i23-i01);
      m[8] = i00-i11-i22+i33;

      pose.p[0] = initialPosition[0]+m[0]*p0+m[3]*p1+m[6]*p2;
      pose.p[1] = initialPosition[1]+m[1]*p0+m[4]*p1+m[7]*p2;
      pose.p[2] = initialPosition[2]+m[2]*p0+m[5]*p1+m[8]*p2;

      pose.q[0] = i0*b0-i1*b1-i2*b2-i3*b3;
      pose.q[1] = i1*b0+i0*b1-i3*b2+i2*b3;
      pose.q[2] = i2*b0+i3*b1+i0*b2-i1*b3;
      pose.q[3] = i3*b0-i2*b1+i1*b2+i0*b3;

//       printf("\nqi = [%f,%f,%f,%f]", i0, i1, i2, i3);
//       printf("\nqA = [%f,%f,%f,%f]", q0, q1, q2, q3);
//       printf("\nqB = [%f,%f,%f,%f]", pose.q[0], pose.q[1], pose.q[2], pose.q[3]);

      return;
    }

    void transformTangentPose(tom::TangentPose& tangentPose)
    {
      double i0 = initialQuaternion[0];
      double i1 = initialQuaternion[1];
      double i2 = initialQuaternion[2];
      double i3 = initialQuaternion[3];
      double i00 = i0*i0;
      double i11 = i1*i1;
      double i22 = i2*i2;
      double i33 = i3*i3;
      double i01 = i0*i1;
      double i12 = i1*i2;
      double i23 = i2*i3;
      double i03 = i0*i3;
      double i02 = i0*i2;
      double i13 = i1*i3;
      
      double r0 = tangentPose.r[0];
      double r1 = tangentPose.r[1];
      double r2 = tangentPose.r[2];
      double s0 = tangentPose.s[0];
      double s1 = tangentPose.s[1];
      double s2 = tangentPose.s[2];
      
      std::vector<double> m(9, 0.0);

      m[0] = i00+i11-i22-i33;
      m[1] = 2.0*(i12+i03);
      m[2] = 2.0*(i13-i02);
      m[3] = 2.0*(i12-i03);
      m[4] = i00-i11+i22-i33;
      m[5] = 2.0*(i23+i01);
      m[6] = 2.0*(i13+i02);
      m[7] = 2.0*(i23-i01);
      m[8] = i00-i11-i22+i33;
      
      tangentPose.r[0] = m[0]*r0+m[3]*r1+m[6]*r2;
      tangentPose.r[1] = m[1]*r0+m[4]*r1+m[7]*r2;
      tangentPose.r[2] = m[2]*r0+m[5]*r1+m[8]*r2;
      
      tangentPose.s[0] = m[0]*s0+m[3]*s1+m[6]*s2;
      tangentPose.s[1] = m[1]*s0+m[4]*s1+m[7]*s2;
      tangentPose.s[2] = m[2]*s0+m[5]*s1+m[8]*s2;
      
      transformPose(tangentPose);
      return;
    }
    
    void evaluateGeneral(const double k, tom::Pose& pose)
    {
      // position and velocity A=[1,tau;0,1] B=[0.5*tau*tau;tau]
      static const double normalizedRotationalMass = normalizedMass*radius*radius; // point mass at radius
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
        convertForces(fL[b], fR[b], a[b], xRate[b], yRate[b], aRate[b], fx[b], fy[b], fa[b]);
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

      convertForces(fL[bBase], fR[bBase], a[bBase], xRate[bBase], yRate[bBase], aRate[bBase], 
        fx[bBase], fy[bBase], fa[bBase]);
      halfAngle = 0.5*(a[bBase]+tRemain*aRate[bBase]+ct1*fa[bBase]);
      pose.p[0] = x[bBase]+tRemain*xRate[bBase]+ct0*fx[bBase];
      pose.p[1] = y[bBase]+tRemain*yRate[bBase]+ct0*fy[bBase];
      pose.p[2] = 0.0;
      pose.q[0] = cos(halfAngle);
      pose.q[1] = 0.0;
      pose.q[2] = 0.0;
      pose.q[3] = sin(halfAngle);

//       printf("\nfL[bBase] = %0.16f", fL[bBase]);
//       printf("\nfR[bBase] = %0.16f", fR[bBase]);
//       printf("\nfx[bBase] = %0.16f", fx[bBase]);
//       printf("\nfy[bBase] = %0.16f", fy[bBase]);
//       printf("\nfa[bBase] = %0.16f", fa[bBase]);
//       printf("\npose.p[0] = %0.16f", pose.p[0]);
//       printf("\npose.p[1] = %0.16f", pose.p[1]);
//       printf("\npose.p[2] = %0.16f", pose.p[2]);
//       printf("\npose.q[0] = %0.16f", pose.q[0]);
//       printf("\npose.q[1] = %0.16f", pose.q[1]);
//       printf("\npose.q[2] = %0.16f", pose.q[2]);
//       printf("\npose.q[3] = %0.16f", pose.q[3]);

      return;
    }

    void evaluateTangentPose(const double k, tom::TangentPose& tangentPose)
    {
      static const double normalizedRotationalMass = normalizedMass*radius*radius; // point mass at radius
      static const tom::TangentPose nullTangentPose;
      static tom::TangentPose tP;
      double K;
      double halfAngle;
      double ct2;
      double ct3;
      double tRemain;
      uint32_t bBase;

      K = static_cast<double>(pL.size());

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
        halfAngle = atan2(tP.q[3], tP.q[0])-0.5*tRemain*tP.s[0];
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

        convertForces(fL[bBase], fR[bBase], a[bBase], xRate[bBase], yRate[bBase], aRate[bBase], 
          fx[bBase], fy[bBase], fa[bBase]);
        tangentPose.r[0] = xRate[bBase]+ct2*fx[bBase];
        tangentPose.r[1] = yRate[bBase]+ct2*fy[bBase];
        tangentPose.r[2] = 0.0;
        tangentPose.s[0] = 0.0;
        tangentPose.s[1] = 0.0;
        tangentPose.s[2] = (aRate[bBase]+ct3*fa[bBase]);
      }
      return;
    }

    void evaluatePose(const double k, tom::Pose& pose)
    {
      static const tom::Pose nullPose;
      static tom::TangentPose tP;
      double K;
      double halfAngle;
      double dt;

      K = static_cast<double>(pL.size());

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
        halfAngle = atan2(tP.q[3], tP.q[0])-0.5*dt*tP.s[0];
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
      return;
    }

  public:
    ShipDynamics(const double initialTime, const std::string uri) :
      tom::DynamicModel(initialTime, uri)
    {
      static const double DTOR = PI/180.0;
      static const unsigned reserve = 1024;
      static double quat[4];

      initialLongitude = 0.0;
      initialLatitude = 0.0;
      initialHeading = 0.0;     

      interval.first = initialTime;
      interval.second = initialTime;
      firstNewBlock = 0;

      // begin with no parameter blocks
      pL.resize(0);
      pR.resize(0);
      fL.resize(0);
      fR.resize(0);
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
      pL.reserve(reserve);
      pR.reserve(reserve);
      fL.reserve(reserve);
      fR.reserve(reserve);
      fx.reserve(reserve);
      fy.reserve(reserve);
      fa.reserve(reserve);
      x.reserve(reserve);
      y.reserve(reserve);
      a.reserve(reserve);
      xRate.reserve(reserve);
      yRate.reserve(reserve);
      aRate.reserve(reserve);

      // set initial position and orientation from URI
      if(!uri.compare(0, 5, "moos:"))
      {
        sscanf(uri.c_str(), "moos:longitude=%lf,latitude=%lf,heading=%lf", &initialLongitude, &initialLatitude, &initialHeading);
      }

      // convert from degrees to radians
      initialLongitude *= DTOR;
      initialLatitude *= DTOR;
      initialHeading *= DTOR;

      // set initial frame
      tom::WGS84::llaToECEF(initialLongitude, initialLatitude, 0.0, initialPosition[0], initialPosition[1], 
        initialPosition[2]);
      tom::Rotation::eulerToQuat(0.0, -PI/2.0, 0.0, initialQuaternion);
      tom::Rotation::eulerToQuat(-initialHeading, 0.0, 0.0, quat);
      tom::Rotation::quatMult(quat, initialQuaternion, initialQuaternion);
      tom::Rotation::eulerToQuat(0.0, -initialLatitude, 0.0, quat);
      tom::Rotation::quatMult(quat, initialQuaternion, initialQuaternion);
      tom::Rotation::eulerToQuat(0.0, 0.0, initialLongitude, quat);
      tom::Rotation::quatMult(quat, initialQuaternion, initialQuaternion);

      //printf("\nX=%0.16f,Y=%0.16f,Z=%0.16f", initialPosition[0], initialPosition[1], initialPosition[2]);
      //printf("\ninitialQuaternion=[%0.16f,%0.16f,%0.16f,%0.16f]", initialQuaternion[0], initialQuaternion[1], initialQuaternion[2], initialQuaternion[3]);
    }

    hidi::TimeInterval domain(void)
    {
      return (interval);
    }

    void evaluate(const double& time, tom::Pose& pose)
    {
      static double k;
      k = rate*(time-interval.first);
      evaluatePose(k, pose);
      transformPose(pose);
      return;
    }

    void tangent(const double& time, tom::TangentPose& tangentPose)
    {
      static double k;
      k = rate*(time-interval.first);
      evaluateTangentPose(k, tangentPose);
      transformTangentPose(tangentPose);
      return;
    }

    uint32_t numInitial(void)
    {
      return (0);
    }

    uint32_t numExtension(void)
    {
      return (2);
    }

    uint32_t numBlocks(void)
    {
      return (static_cast<uint32_t>(pL.size()));
    }

    uint32_t getInitial(const uint32_t parameterIndex)
    {
      throw("ShipDynamics: has no initial integer parameters");
      return (0);
    }

    uint32_t getExtension(const uint32_t blockIndex, const uint32_t parameterIndex)
    {
      if(blockIndex>=numBlocks())
      {
        throw("ShipDynamics: extension integer block index is out of range");
      }
      switch(parameterIndex)
      {
        case 0:
          return (pL[blockIndex]);
        case 1:
          return (pR[blockIndex]);
        default:
          throw("ShipDynamics: extension integer parameter index is out of range");
          return (0);
      }
    }

    void setInitial(const uint32_t parameterIndex, const uint32_t value)
    {
      throw("ShipDynamics: has no initial integer parameters");
      return;
    }

    void setExtension(const uint32_t blockIndex, const uint32_t parameterIndex, const uint32_t value)
    {
      if(blockIndex>=numBlocks())
      {
        throw("ShipDynamics: extension integer block index is out of range");
      }
      switch(parameterIndex)
      {
        case 0:
          pL[blockIndex] = value;
          fL[blockIndex] = paramToForce(value);
          break;
        case 1:
          pR[blockIndex] = value;
          fR[blockIndex] = paramToForce(value);
          break;
        default:
          throw("ShipDynamics: extension integer parameter index is out of range");
      }
      firstNewBlock = std::min(firstNewBlock, blockIndex);
    }

    double computeInitialCost(void)
    {
      return (0.0);
    }

    double computeExtensionCost(const uint32_t blockIndex)
    {
      double f0, f1;
      double cost;
      f0 = fL[blockIndex];
      f1 = fR[blockIndex];
      cost = 0.5*(f0*f0+f1*f1);
      return (cost);
    }

    void extend(void)
    {
      static const uint32_t halfIntMax = static_cast<uint32_t>(floor(4294967295.0/2.0));
      static const double force = paramToForce(halfIntMax);
      size_t oldSize = x.size();
      size_t newSize = oldSize+1;
      pL.resize(oldSize, halfIntMax);
      pR.resize(oldSize, halfIntMax);
      fL.resize(oldSize, force);
      fR.resize(oldSize, force);
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
      double initialTime = this->interval.first;
      std::string uri = "";
      ShipDynamics* obj = new ShipDynamics(initialTime, uri);

      // parameters
      obj->pL = this->pL;
      obj->pR = this->pR;

      // forces
      obj->fL = this->fL;
      obj->fR = this->fR;
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
      return ("Motion model of a rigid body constrained to zero altitude with unit inertia that undergoes forcing.");
    }

    static tom::DynamicModel* componentFactory(const double initialTime, const std::string uri)
    {
      return (new ShipDynamics(initialTime, uri));
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
      ShipDynamics::initialize("ShipDynamics");
    }
  } _Initializer;
}

#include "ShipDynamicsConfig.h"
