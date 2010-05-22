#include "mex.h"
#include "tommas.h"

void convert(const mxArray* array, uint32_t& value)
{
  if(mxGetClassID(array)!=mxUINT32_CLASS)
  {
    mexErrMsgTxt("input array must be uint32");
  }
  value=(*static_cast<uint32_t*>(mxGetData(array)));
  return;
}

void convert(const mxArray* array, std::string& cppString)
{
  unsigned N = mxGetNumberOfElements(array)+1;
  char *cString = new char[N];
  if(mxGetClassID(array)!=mxCHAR_CLASS)
  {
    mexErrMsgTxt("input array must be char");
  }
  mxGetString(array,cString,N);
  cppString = cString;
  delete[] cString;
  return;
}

void convert(const mxArray* array, tommas::TimeInterval& value)
{
  value.first=mxGetScalar(mxGetProperty(array,0,"first"));
  value.second=mxGetScalar(mxGetProperty(array,0,"second"));
  return;
}

void convert(const mxArray* array, tommas::Edge& value)
{
  value.first=(*static_cast<uint32_t*>(mxGetData(mxGetProperty(array,0,"first"))));
  value.second=(*static_cast<uint32_t*>(mxGetData(mxGetProperty(array,0,"second"))));
  return;
}

void convert(const mxArray* array, std::vector<tommas::Pose>& pose)
{
  mxArray* p;
  mxArray* q;
  double* pp;
  double* pq;
  tommas::Pose* pPose;
  unsigned n;
  unsigned N=mxGetNumberOfElements(array);
  pose.resize(N);
  for( n=0 ; n<N ; ++n )
  {
    p=mxGetProperty(array,n,"p");
    q=mxGetProperty(array,n,"q");
    pp=mxGetPr(p);
    pq=mxGetPr(q);
    pPose=&pose[n];
    pPose->p[0]=pp[0];
    pPose->p[1]=pp[1];
    pPose->p[2]=pp[2];
    pPose->q[0]=pq[0];
    pPose->q[1]=pq[1];
    pPose->q[2]=pq[2];
    pPose->q[3]=pq[3];
  }
  return;
}

void convert(const mxArray* array, std::vector<tommas::TangentPose>& tangentPose)
{
  mxArray* p;
  mxArray* q;
  mxArray* r;
  mxArray* s;
  double* pp;
  double* pq;
  double* pr;
  double* ps;
  tommas::TangentPose* pTangentPose;
  unsigned n;
  unsigned N=mxGetNumberOfElements(array);
  tangentPose.resize(N);
  for( n=0 ; n<N ; ++n )
  {
    p=mxGetProperty(array,n,"p");
    q=mxGetProperty(array,n,"q");
    r=mxGetProperty(array,n,"r");
    s=mxGetProperty(array,n,"s");
    pp=mxGetPr(p);
    pq=mxGetPr(q);
    pr=mxGetPr(r);
    ps=mxGetPr(s);
    pTangentPose=&tangentPose[n];
    pTangentPose->p[0]=pp[0];
    pTangentPose->p[1]=pp[1];
    pTangentPose->p[2]=pp[2];
    pTangentPose->q[0]=pq[0];
    pTangentPose->q[1]=pq[1];
    pTangentPose->q[2]=pq[2];
    pTangentPose->q[3]=pq[3];
    pTangentPose->r[0]=pr[0];
    pTangentPose->r[1]=pr[1];
    pTangentPose->r[2]=pr[2];
    pTangentPose->s[0]=ps[0];
    pTangentPose->s[1]=ps[1];
    pTangentPose->s[2]=ps[2];
    pTangentPose->s[3]=ps[3];
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

void convert(const std::vector<tommas::WorldTime>& time, mxArray*& array)
{
  double* pTime;
  unsigned n;
  unsigned N=time.size();
  array=mxCreateDoubleMatrix(1,N,mxREAL);
  pTime=mxGetPr(array);
  for( n=0 ; n<N ; ++n )
  {
    pTime[n]=static_cast<tommas::WorldTime>(time[n]);
  }
  return;
}

void convert(const std::vector<tommas::Edge>& edge, const mxArray*& source, mxArray*& array)
{
  mxArray* prhs[2];
  mxArray* sz;
  mxArray* first;
  mxArray* second;
  mxArray* singleEdge;
  double* pfirst;
  double* psecond;
  double* psz;
  unsigned n;
  unsigned N=edge.size();
  singleEdge=mxDuplicateArray(source);
  sz=mxCreateDoubleMatrix(1,2,mxREAL);
  psz=mxGetPr(sz);
  psz[0]=1;
  psz[1]=N;
  prhs[0]=singleEdge;
  prhs[1]=sz;
  mexCallMATLAB(1,&array,2,prhs,"repmat");
  for( n=0 ; n<N ; ++n )
  {
    first=mxGetProperty(array,n,"first");
    second=mxGetProperty(array,n,"second");
    pfirst=mxGetPr(first);
    psecond=mxGetPr(second);
    pfirst[0]=edge[n].first;
    psecond[0]=edge[n].second;
  }
  return;
}

class TrajectoryWrapper : public tommas::Trajectory
{
  public:
    tommas::TimeInterval domain(void)
    {
      mxArray* lhs;
      tommas::TimeInterval timeInterval;
      mexEvalString("interval=domain(x);"); // depends on Trajectory named 'x' in MATLAB workspace
      lhs=mexGetVariable("caller","interval");
      convert(lhs,timeInterval);
      mxDestroyArray(lhs);
      return timeInterval;
    }
    
    void evaluate(const std::vector<tommas::WorldTime>& time,std::vector<tommas::Pose>& pose)
    {
      mxArray* rhs;
      mxArray* lhs;
      convert(time,rhs);
      mexPutVariable("caller","t",rhs);
      mexEvalString("pose=evaluate(x,t);"); // depends on Trajectory named 'x' in MATLAB workspace
      lhs=mexGetVariable("caller","pose");
      convert(lhs,pose);
      mxDestroyArray(lhs);
      return;
    }

    void tangent(const std::vector<tommas::WorldTime>& time,std::vector<tommas::TangentPose>& tangentPose)
    {
      mxArray* rhs;
      mxArray* lhs;
      convert(time,rhs);
      mexPutVariable("caller","t",rhs);
      mexEvalString("tangentPose=tangent(x,t);"); // depends on Trajectory named 'x' in MATLAB workspace
      lhs=mexGetVariable("caller","tangentPose");
      convert(lhs,tangentPose);
      mxDestroyArray(lhs);
      return;
    }
};

enum MeasureMember
{
  undefined,
  refresh,
  hasData,
  first,
  last,
  getTime,
  findEdges,
  computeEdgeCost
};

void safeMexFunction(int& nlhs, mxArray**& plhs, int& nrhs, const mxArray**& prhs)
{
  static std::map<std::string,MeasureMember> memberMap;
  static std::vector<tommas::Measure*> instance;
  static bool initialized=false;

  if(!initialized)
  {
    tommas::tommas();
    memberMap["refresh"]=refresh;
    memberMap["hasData"]=hasData;
    memberMap["first"]=first;
    memberMap["last"]=last;
    memberMap["getTime"]=getTime;
    memberMap["findEdges"]=findEdges;
    memberMap["computeEdgeCost"]=computeEdgeCost;
    initialized=true;
  }

  mxAssert(nrhs>=2,"function requires at least 2 arguments");
  if(mxIsChar(prhs[0]))
  {
    std::string pkg;
    std::string uri;
    tommas::Measure* obj;
    uint32_t numInstances = instance.size();

    convert(prhs[0],pkg);
    convert(prhs[1],uri);
    obj = tommas::Measure::factory(pkg,uri);
    if(obj==NULL)
    {
      mexErrMsgTxt("failed to instantiate the specified Measure");
    }
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

    if(handle<instance.size())
    {
      mexErrMsgTxt("requested invalid handle to Measure");
    }
    switch(memberMap[memberName])
    {
    case undefined:
      mexErrMsgTxt("unrecognized member function in call to Measure");
      break;
      
    case refresh:
      instance[handle]->refresh();
      break;

    case hasData:
      convert(instance[handle]->hasData(),plhs[0]);
      break;

    case first:
      convert(instance[handle]->first(),plhs[0]);
      break;
      
    case last:
      convert(instance[handle]->last(),plhs[0]);
      break;

    case getTime:
      uint32_t k;
      convert(prhs[2],k);
      convert(instance[handle]->getTime(k),plhs[0]);
      break;

    case findEdges:
    {
      uint32_t kaSpan;
      uint32_t kbSpan;
      convert(prhs[3],kaSpan);
      convert(prhs[4],kbSpan);
      convert(instance[handle]->findEdges(kaSpan,kbSpan),prhs[2],plhs[0]);
      break;
    }

    case computeEdgeCost:
    {
      TrajectoryWrapper x;
      tommas::Edge edge;
      convert(prhs[2],edge);
      convert(instance[handle]->computeEdgeCost(x,edge),plhs[0]);
      break;
    }
    }
  }
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
  try
  {
    safeMexFunction(nlhs,plhs,nrhs,prhs);
  }
  catch(std::exception& e)
  {
    mexErrMsgTxt(e.what());
  }
  catch(const char* str)
  {
    mexErrMsgTxt(str);
  }
  catch(...)
  {
    mexErrMsgTxt("MeasureWrapper: unhandled exception");
  }
  return;
}
