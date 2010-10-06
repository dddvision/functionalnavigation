#include "mex.h"
#include "Measure.h"

void convert(const mxArray* array, uint32_t& value)
{
  if(mxGetClassID(array)!=mxUINT32_CLASS)
  {
    mexErrMsgTxt("input array must be uint32");
  }
  value = (*static_cast<uint32_t*>(mxGetData(array)));
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
  mxGetString(array, cString, N);
  cppString = cString;
  delete[] cString;
  return;
}

void convert(const mxArray* array, tom::TimeInterval& value)
{
  value.first = mxGetScalar(mxGetProperty(array, 0, "first"));
  value.second = mxGetScalar(mxGetProperty(array, 0, "second"));
  return;
}

void convert(const mxArray* array, tom::GraphEdge& value)
{
  value.first = (*static_cast<uint32_t*>(mxGetData(mxGetProperty(array, 0, "first"))));
  value.second = (*static_cast<uint32_t*>(mxGetData(mxGetProperty(array, 0, "second"))));
  return;
}

void convert(const mxArray* array, std::vector<tom::Pose>& pose)
{
  mxArray* p;
  mxArray* q;
  double* pp;
  double* pq;
  tom::Pose* pPose;
  unsigned n;
  unsigned N = mxGetNumberOfElements(array);
  pose.resize(N);
  for(n = 0; n<N; ++n)
  {
    p = mxGetProperty(array, n, "p");
    q = mxGetProperty(array, n, "q");
    pp = mxGetPr(p);
    pq = mxGetPr(q);
    pPose = &pose[n];
    pPose->p[0] = pp[0];
    pPose->p[1] = pp[1];
    pPose->p[2] = pp[2];
    pPose->q[0] = pq[0];
    pPose->q[1] = pq[1];
    pPose->q[2] = pq[2];
    pPose->q[3] = pq[3];
  }
  return;
}

void convert(const mxArray* array, std::vector<tom::TangentPose>& tangentPose)
{
  mxArray* p;
  mxArray* q;
  mxArray* r;
  mxArray* s;
  double* pp;
  double* pq;
  double* pr;
  double* ps;
  tom::TangentPose* pTangentPose;
  unsigned n;
  unsigned N = mxGetNumberOfElements(array);
  tangentPose.resize(N);
  for(n = 0; n<N; ++n)
  {
    p = mxGetProperty(array, n, "p");
    q = mxGetProperty(array, n, "q");
    r = mxGetProperty(array, n, "r");
    s = mxGetProperty(array, n, "s");
    pp = mxGetPr(p);
    pq = mxGetPr(q);
    pr = mxGetPr(r);
    ps = mxGetPr(s);
    pTangentPose = &tangentPose[n];
    pTangentPose->p[0] = pp[0];
    pTangentPose->p[1] = pp[1];
    pTangentPose->p[2] = pp[2];
    pTangentPose->q[0] = pq[0];
    pTangentPose->q[1] = pq[1];
    pTangentPose->q[2] = pq[2];
    pTangentPose->q[3] = pq[3];
    pTangentPose->r[0] = pr[0];
    pTangentPose->r[1] = pr[1];
    pTangentPose->r[2] = pr[2];
    pTangentPose->s[0] = ps[0];
    pTangentPose->s[1] = ps[1];
    pTangentPose->s[2] = ps[2];
    pTangentPose->s[3] = ps[3];
  }
  return;
}

void convert(const double value, mxArray*& array)
{
  array = mxCreateDoubleScalar(value);
  return;
}

void convert(const uint32_t value, mxArray*& array)
{
  array = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  (*static_cast<uint32_t*>(mxGetData(array))) = value;
  return;
}

void convert(const bool value, mxArray*& array)
{
  array = mxCreateLogicalScalar(value);
  return;
}

void convert(const std::vector<tom::WorldTime>& time, mxArray*& array)
{
  double* pTime;
  unsigned n;
  unsigned N = time.size();
  array = mxCreateDoubleMatrix(1, N, mxREAL);
  pTime = mxGetPr(array);
  for(n = 0; n<N; ++n)
  {
    pTime[n] = static_cast<tom::WorldTime>(time[n]);
  }
  return;
}

void convert(const std::vector<tom::GraphEdge>& graphEdge, const mxArray*& source, mxArray*& array)
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
  unsigned N = graphEdge.size();
  singleEdge = mxDuplicateArray(source);
  sz = mxCreateDoubleMatrix(1, 2, mxREAL);
  psz = mxGetPr(sz);
  psz[0] = 1;
  psz[1] = N;
  prhs[0] = singleEdge;
  prhs[1] = sz;
  mexCallMATLAB(1, &array, 2, prhs, "repmat");
  for(n = 0; n<N; ++n)
  {
    first = mxGetProperty(array, n, "first");
    second = mxGetProperty(array, n, "second");
    pfirst = mxGetPr(first);
    psecond = mxGetPr(second);
    pfirst[0] = graphEdge[n].first;
    psecond[0] = graphEdge[n].second;
  }
  return;
}

class TrajectoryBridge : public tom::Trajectory
{
public:
  tom::TimeInterval domain(void)
  {
    mxArray* lhs;
    tom::TimeInterval timeInterval;
    mexEvalString("interval=domain(x);"); // depends on Trajectory named 'x' in MATLAB workspace
    lhs = mexGetVariable("caller", "interval");
    convert(lhs, timeInterval);
    mxDestroyArray(lhs);
    return timeInterval;
  }

  void evaluate(const std::vector<tom::WorldTime>& time, std::vector<tom::Pose>& pose)
  {
    mxArray* rhs;
    mxArray* lhs;
    convert(time, rhs);
    mexPutVariable("caller", "t", rhs);
    mexEvalString("pose=evaluate(x,t);"); // depends on Trajectory named 'x' in MATLAB workspace
    lhs = mexGetVariable("caller", "pose");
    convert(lhs, pose);
    mxDestroyArray(lhs);
    return;
  }

  void tangent(const std::vector<tom::WorldTime>& time, std::vector<tom::TangentPose>& tangentPose)
  {
    mxArray* rhs;
    mxArray* lhs;
    convert(time, rhs);
    mexPutVariable("caller", "t", rhs);
    mexEvalString("tangentPose=tangent(x,t);"); // depends on Trajectory named 'x' in MATLAB workspace
    lhs = mexGetVariable("caller", "tangentPose");
    convert(lhs, tangentPose);
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
  static std::map<std::string, MeasureMember> memberMap;
  static std::vector<tom::Measure*> instance;
  static bool initialized = false;

  if(!initialized)
  {
    memberMap["refresh"] = refresh;
    memberMap["hasData"] = hasData;
    memberMap["first"] = first;
    memberMap["last"] = last;
    memberMap["getTime"] = getTime;
    memberMap["findEdges"] = findEdges;
    memberMap["computeEdgeCost"] = computeEdgeCost;
    initialized = true;
  }

  mxAssert(nrhs>=2, "function requires at least 2 arguments");
  if(mxIsChar(prhs[0]))
  {
    std::string name;
    std::string uri;
    tom::Measure* obj;
    uint32_t numInstances = instance.size();

    convert(prhs[0], name);
    convert(prhs[1], uri);
    obj = tom::Measure::create(name, uri);
    if(obj==NULL)
    {
      mexErrMsgTxt("failed to instantiate the specified Measure");
    }
    instance.resize(numInstances+1);
    instance[numInstances] = obj;
    convert(numInstances, plhs[0]);
  }
  else
  {
    uint32_t handle;
    std::string memberName;

    convert(prhs[0], handle);
    convert(prhs[1], memberName);

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
        TrajectoryBridge x;
        instance[handle]->refresh(x);
        break;

      case hasData:
        convert(instance[handle]->hasData(), plhs[0]);
        break;

      case first:
        convert(instance[handle]->first(), plhs[0]);
        break;

      case last:
        convert(instance[handle]->last(), plhs[0]);
        break;

      case getTime:
        uint32_t n;
        convert(prhs[2], n);
        convert(instance[handle]->getTime(n), plhs[0]);
        break;

        // TODO: implement this bridge function properly
      case findEdges:
      {
        uint32_t naSpan;
        uint32_t nbSpan;
        convert(prhs[2], naMin);
        convert(prhs[3], naMax);
        convert(prhs[4], nbMin);
        convert(prhs[5], nbMax);
        convert(instance[handle]->findEdges(naMin, naMax, nbMin, nbMax), plhs[0]);
        break;
      }

      case computeEdgeCost:
      {
        TrajectoryBridge x;
        tom::GraphEdge graphEdge;
        convert(prhs[2], graphEdge);
        convert(instance[handle]->computeEdgeCost(x, graphEdge), plhs[0]);
        break;
      }
    }
  }
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
  try
  {
    safeMexFunction(nlhs, plhs, nrhs, prhs);
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
    mexErrMsgTxt("MeasureBridge: unhandled exception");
  }
  return;
}
