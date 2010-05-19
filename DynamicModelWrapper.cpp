#include "mex.h"
#include "tommas.h"

void convert(const mxArray* array, double& value)
{
  value=(*static_cast<double*>(mxGetData(array)));
  return;
}

void convert(const mxArray* array, uint32_t& value)
{
  value=(*static_cast<uint32_t*>(mxGetData(array)));
  return;
}

void convert(const mxArray* array, bool& value)
{
  value=(*static_cast<bool*>(mxGetLogicals(array)));
  return;
}

void convert(const mxArray* array, std::string& cppString)
{
  unsigned N = mxGetNumberOfElements(array)+1;
  char *cString = new char[N];
  mxGetString(array,cString,N);
  cppString = cString;
  delete[] cString;
  return;
}

void convert(const mxArray* array, std::vector<tommas::WorldTime>& cppTime)
{
  unsigned n;
  unsigned N=mxGetNumberOfElements(array);
  double* mTime=static_cast<double*>(mxGetData(array));

  cppTime.resize(N);
  for( n=0 ; n<N ; ++n )
  {
    cppTime[n]=mTime[n];
  }
  return;
}

void convert(const double value, mxArray*& array)
{
  array=mxCreateDoubleScalar(value);
  return;
}

void convert(const uint32_t value, mxArray*& array)
{
  array=mxCreateNumericMatrix(1,1,mxUINT32_CLASS,mxREAL);
  (*static_cast<uint32_t*>(mxGetData(array)))=value;
  return;
}

void convert(const bool value, mxArray*& array)
{
  array=mxCreateLogicalScalar(value);
  return;
}

void convert(const tommas::TimeInterval& timeInterval, mxArray*& array)
{
  static const char* fields[]={"first","second"};
  mxArray* first;
  mxArray* second;
  array=mxCreateStructMatrix(1,1,2,fields);
  first=mxCreateDoubleScalar(timeInterval.first);
  second=mxCreateDoubleScalar(timeInterval.second);
  mxSetFieldByNumber(array,0,0,first);
  mxSetFieldByNumber(array,0,1,second);
  return;
}

void convert(const std::vector<tommas::Pose>& pose, mxArray*& array)
{
  static const char* fields[]={"p","q"};
  mxArray* p;
  mxArray* q;
  double* pp;
  double* pq;
  unsigned n;
  unsigned N=pose.size();
  array=mxCreateStructMatrix(1,N,2,fields);
  for( n=0 ; n<N ; ++n )
  {
    p=mxCreateDoubleMatrix(3,1,mxREAL);
    q=mxCreateDoubleMatrix(4,1,mxREAL);
    pp=mxGetPr(p);
    pq=mxGetPr(q);
    pp[0]=pose[n].p[0];
    pp[1]=pose[n].p[1];
    pp[2]=pose[n].p[2];
    pq[0]=pose[n].q[0];
    pq[1]=pose[n].q[1];
    pq[2]=pose[n].q[2];
    pq[3]=pose[n].q[3];
    mxSetFieldByNumber(array,n,0,p);
    mxSetFieldByNumber(array,n,1,q);
  }
  return;
}

void convert(const std::vector<tommas::TangentPose>& tangentPose, mxArray*& array)
{
  static const char* fields[]={"p","q","r","s"};
  mxArray* p;
  mxArray* q;
  mxArray* r;
  mxArray* s;
  double* pp;
  double* pq;
  double* pr;
  double* ps;
  unsigned n;
  unsigned N=tangentPose.size();
  array=mxCreateStructMatrix(1,N,4,fields);
  for( n=0 ; n<N ; ++n )
  {
    p=mxCreateDoubleMatrix(3,1,mxREAL);
    q=mxCreateDoubleMatrix(4,1,mxREAL);
    r=mxCreateDoubleMatrix(3,1,mxREAL);
    s=mxCreateDoubleMatrix(4,1,mxREAL);
    pp=mxGetPr(p);
    pq=mxGetPr(q);
    pr=mxGetPr(r);
    ps=mxGetPr(s);
    pp[0]=tangentPose[n].p[0];
    pp[1]=tangentPose[n].p[1];
    pp[2]=tangentPose[n].p[2];
    pq[0]=tangentPose[n].q[0];
    pq[1]=tangentPose[n].q[1];
    pq[2]=tangentPose[n].q[2];
    pq[3]=tangentPose[n].q[3];
    pr[0]=tangentPose[n].r[0];
    pr[1]=tangentPose[n].r[1];
    pr[2]=tangentPose[n].r[2];
    ps[0]=tangentPose[n].s[0];
    ps[1]=tangentPose[n].s[1];
    ps[2]=tangentPose[n].s[2];
    ps[3]=tangentPose[n].s[3];
    mxSetFieldByNumber(array,n,0,p);
    mxSetFieldByNumber(array,n,1,q);
    mxSetFieldByNumber(array,n,2,r);
    mxSetFieldByNumber(array,n,3,s);
  }
  return;
}

enum DynamicModelMember
{
  undefined,
  updateRate,
  numInitialLogical,
  numInitialUint32,
  numExtensionLogical,
  numExtensionUint32,
  numExtensionBlocks,
  getInitialLogical,
  getInitialUint32,
  getExtensionLogical,
  getExtensionUint32,
  setInitialLogical,
  setInitialUint32,
  setExtensionLogical,
  setExtensionUint32,
  computeInitialBlockCost,
  computeExtensionBlockCost,
  extend,
  domain,
  evaluate,
  tangent
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  static std::map<std::string,DynamicModelMember> memberMap;
  static std::vector<tommas::DynamicModel*> instance;
  static bool initialized=false;

  if(!initialized)
  {
    tommas::tommas();
    memberMap["updateRate"]=updateRate;
    memberMap["numInitialLogical"]=numInitialLogical;
    memberMap["numInitialUint32"]=numInitialUint32;
    memberMap["numExtensionLogical"]=numExtensionLogical;
    memberMap["numExtensionUint32"]=numExtensionUint32;
    memberMap["numExtensionBlocks"]=numExtensionBlocks;
    memberMap["getInitialLogical"]=getInitialLogical;
    memberMap["getInitialUint32"]=getInitialUint32;
    memberMap["getExtensionLogical"]=getExtensionLogical;
    memberMap["getExtensionUint32"]=getExtensionUint32;
    memberMap["setInitialLogical"]=setInitialLogical;
    memberMap["setInitialUint32"]=setInitialUint32;
    memberMap["setExtensionLogical"]=setExtensionLogical;
    memberMap["setExtensionUint32"]=setExtensionUint32;
    memberMap["computeInitialBlockCost"]=computeInitialBlockCost;
    memberMap["computeExtensionBlockCost"]=computeExtensionBlockCost;
    memberMap["extend"]=extend;
    memberMap["domain"]=domain;
    memberMap["evaluate"]=evaluate;
    memberMap["tangent"]=tangent;
    initialized=true;
  }
  
  if(mxIsChar(prhs[0]))
  {
    std::string pkg;
    std::string uri;
    tommas::DynamicModel* obj;
    tommas::WorldTime initialTime;
    uint32_t numInstances = instance.size();

    convert(prhs[0],pkg);
    convert(prhs[1],initialTime);
    convert(prhs[2],uri);
    obj = tommas::DynamicModel::factory(pkg,initialTime,uri);
    mxAssert(obj!=NULL,"failed to instantiate the specified DynamicModel");
    instance.resize(numInstances+1);
    instance[numInstances] = obj;
    convert(numInstances,plhs[0]);
  }
  else
  {
    uint32_t handle;
    std::string memberName;

    convert(prhs[0],handle);
    convert(prhs[1],memberName);

    mxAssert(handle<instance.size(),"requested invalid handle to DynamicModel");
    switch(memberMap[memberName])
    {
    case undefined:
      mexErrMsgTxt("unrecognized member function in call to DynamicModel");
      break;
      
    case updateRate:
      convert(instance[handle]->updateRate(),plhs[0]);
      break;

    case numInitialLogical:
      convert(instance[handle]->numInitialLogical(),plhs[0]);
      break;
    
    case numInitialUint32:
      convert(instance[handle]->numInitialUint32(),plhs[0]);
      break;

    case numExtensionLogical:
      convert(instance[handle]->numExtensionLogical(),plhs[0]);
      break;

    case numExtensionUint32:
      convert(instance[handle]->numExtensionUint32(),plhs[0]);
      break;
      
    case numExtensionBlocks:
      convert(instance[handle]->numExtensionBlocks(),plhs[0]);
      break;
      
    case getInitialLogical:
    {
      uint32_t p;
      convert(prhs[2],p);
      convert(instance[handle]->getInitialLogical(p),plhs[0]);
      break;
    }

    case getInitialUint32:
    {
      uint32_t p;
      convert(prhs[2],p);
      convert(instance[handle]->getInitialUint32(p),plhs[0]);
      break;
    }
  
    case getExtensionLogical:
    {
      uint32_t b;
      uint32_t p;
      convert(prhs[2],b);
      convert(prhs[3],p);
      convert(instance[handle]->getExtensionLogical(b,p),plhs[0]);
      break;
    }
  
    case getExtensionUint32:
    {
      uint32_t b;
      uint32_t p;
      convert(prhs[2],b);
      convert(prhs[3],p);
      convert(instance[handle]->getExtensionUint32(b,p),plhs[0]);
      break;
    }

    case setInitialLogical:
    {
      uint32_t p;
      bool v;
      convert(prhs[2],p);
      convert(prhs[3],v);
      instance[handle]->setInitialLogical(p,v);
      break;
    }

    case setInitialUint32:
    {
      uint32_t p;
      uint32_t v;
      convert(prhs[2],p);
      convert(prhs[3],v);
      instance[handle]->setInitialUint32(p,v);
      break;
    }

    case setExtensionLogical:
    {
      uint32_t b;
      uint32_t p;
      bool v;
      convert(prhs[2],b);
      convert(prhs[3],p);
      convert(prhs[4],v);
      instance[handle]->setExtensionLogical(b,p,v);
      break;
    }

    case setExtensionUint32:
    {
      uint32_t b;
      uint32_t p;
      uint32_t v;
      convert(prhs[2],b);
      convert(prhs[3],p);
      convert(prhs[4],v);
      instance[handle]->setExtensionUint32(b,p,v);
      break;
    }

    case computeInitialBlockCost:
      convert(instance[handle]->computeInitialBlockCost(),plhs[0]);
      break;
      
    case computeExtensionBlockCost:
    {
      uint32_t b;
      convert(prhs[2],b);
      convert(instance[handle]->computeExtensionBlockCost(b),plhs[0]);
      break;
    }

    case extend:
    {
      uint32_t num;
      convert(prhs[2],num);
      instance[handle]->extend(num);
      break;
    }

    case domain:
      convert(instance[handle]->domain(),plhs[0]);
      break;
      
    case evaluate:
    {
      std::vector<tommas::WorldTime> time;
      std::vector<tommas::Pose> pose;
      convert(prhs[2],time);
      instance[handle]->evaluate(time,pose);
      convert(pose,plhs[0]);
      break;
    }

    case tangent:
    {
      std::vector<tommas::WorldTime> time;
      std::vector<tommas::TangentPose> tangentPose;
      convert(prhs[2],time);
      instance[handle]->tangent(time,tangentPose);
      convert(tangentPose,plhs[0]);
      break;
    }
    }
  }

  return;
}
