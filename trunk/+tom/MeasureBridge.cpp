#include "mex.h"
#include "Measure.h"

enum MeasureMember
{
    undefined,
    MeasureIsConnected,
    MeasureDescription,
    MeasureFactory,
    refresh,
    hasData,
    first,
    last,
    getTime,
    findEdges,
    computeEdgeCost,
    copy
};

void argcheck(int& narg, int n)
{
  if(n>narg)
  {
    throw("MeasureBridge: too few input arguments");
  }
  return;
}

void convert(const mxArray*& array, double& value)
{
  if(mxGetClassID(array)!=mxDOUBLE_CLASS)
  {
    throw("MeasureBridge: input array must be double.");
  }
  value = (*static_cast<double*>(mxGetData(array)));
  return;
}

void convert(const mxArray* array, uint32_t& value)
{
  if(mxGetClassID(array)!=mxUINT32_CLASS)
  {
    mexErrMsgTxt("MeasureBridge: input array must be uint32");
  }
  value = (*static_cast<uint32_t*>(mxGetData(array)));
  return;
}

void convert(const mxArray* array, std::string& cppString)
{
  unsigned N = mxGetNumberOfElements(array)+1; // add one for terminating character
  char *cString = new char[N];
  if(mxGetClassID(array)!=mxCHAR_CLASS)
  {
    mexErrMsgTxt("MeasureBridge: input array must be char");
  }
  mxGetString(array, cString, N);
  cppString = cString;
  delete[] cString;
  return;
}

void convert(const mxArray* array, hidi::TimeInterval& value)
{
  static mxArray *first;
  static mxArray *second;
  static mxArray *firstDouble;
  static mxArray *secondDouble;

  first = mxGetProperty(array, 0, "first");
  second = mxGetProperty(array, 0, "second");

  mexCallMATLAB(1, &firstDouble, 1, &first, "double");
  mexCallMATLAB(1, &secondDouble, 1, &second, "double");

  value.first = (*static_cast<double*>(mxGetData(firstDouble)));
  value.second = (*static_cast<double*>(mxGetData(secondDouble)));

  mxDestroyArray(first);
  mxDestroyArray(second);
  mxDestroyArray(firstDouble);
  mxDestroyArray(secondDouble);

  return;
}

void convert(const mxArray* array, tom::GraphEdge& value)
{
  static mxArray *first;
  static mxArray *second;

  first = mxGetProperty(array, 0, "first");
  second = mxGetProperty(array, 0, "second");

  value.first = (*static_cast<uint32_t*>(mxGetData(first)));
  value.second = (*static_cast<uint32_t*>(mxGetData(second)));
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

void convert(std::string str, mxArray*& array)
{
  array = mxCreateString(str.c_str());
  return;
}

void convert(const std::vector<double>& time, mxArray*& array)
{
  double* pTime;
  unsigned n;
  unsigned N = time.size();
  array = mxCreateDoubleMatrix(1, N, mxREAL);
  pTime = mxGetPr(array);
  for(n = 0; n<N; ++n)
  {
    pTime[n] = time[n];
  }
  return;
}

void convert(const std::vector<tom::GraphEdge>& graphEdge, mxArray*& array)
{
  static mxArray* prhs[3];
  static mxArray* first;
  static mxArray* second;
  static uint32_t* pfirst;
  static uint32_t* psecond;
  unsigned K = graphEdge.size();
  unsigned k;

  first = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  second = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  pfirst = static_cast<uint32_t*>(mxGetData(first));
  psecond = static_cast<uint32_t*>(mxGetData(second));

  mexCallMATLAB(1, &prhs[0], 0, NULL, "tom.GraphEdge"); // sets prhs[0]
  prhs[1] = mxCreateDoubleScalar(static_cast<double>(K));
  prhs[2] = mxCreateDoubleScalar(1.0);

  mexCallMATLAB(1, &array, 3, prhs, "repmat");

  for(k = 0; k<K; ++k)
  {
    pfirst[0] = graphEdge[k].first;
    psecond[0] = graphEdge[k].second;
    mxSetProperty(array, k, "first", first);
    mxSetProperty(array, k, "second", second);
  }
  return;
}

class TrajectoryBridge : public tom::Trajectory
{
public:
  hidi::TimeInterval domain(void)
  {
    static mxArray* lhs;
    static hidi::TimeInterval timeInterval;
    mexEvalString("interval=x.domain();"); // depends on Trajectory named 'x' in MATLAB workspace
    lhs = mexGetVariable("caller", "interval");
    convert(lhs, timeInterval);
    mxDestroyArray(lhs);
    return timeInterval;
  }

  void evaluate(const std::vector<double>& time, std::vector<tom::Pose>& pose)
  {
    static mxArray* rhs;
    static mxArray* lhs;
    convert(time, rhs);
    mexPutVariable("caller", "t", rhs);
    mexEvalString("pose=x.evaluate(t);"); // depends on Trajectory named 'x' in MATLAB workspace
    lhs = mexGetVariable("caller", "pose");
    convert(lhs, pose);
    mxDestroyArray(lhs);
    return;
  }

  void tangent(const std::vector<double>& time, std::vector<tom::TangentPose>& tangentPose)
  {
    static mxArray* rhs;
    static mxArray* lhs;
    convert(time, rhs);
    mexPutVariable("caller", "t", rhs);
    mexEvalString("tangentPose=x.tangent(t);"); // depends on Trajectory named 'x' in MATLAB workspace
    lhs = mexGetVariable("caller", "tangentPose");
    convert(lhs, tangentPose);
    mxDestroyArray(lhs);
    return;
  }
};

void safeMexFunction(int& nlhs, mxArray**& plhs, int& nrhs, const mxArray**& prhs)
{
  static std::map<std::string, MeasureMember> memberMap;
  static std::vector<tom::Measure*> instance;
  static bool initialized = false;
  static std::string memberName;

  if(!initialized)
  {
    memberMap["MeasureIsConnected"] = MeasureIsConnected;
    memberMap["MeasureDescription"] = MeasureDescription;
    memberMap["MeasureFactory"] = MeasureFactory;
    memberMap["refresh"] = refresh;
    memberMap["hasData"] = hasData;
    memberMap["first"] = first;
    memberMap["last"] = last;
    memberMap["getTime"] = getTime;
    memberMap["findEdges"] = findEdges;
    memberMap["computeEdgeCost"] = computeEdgeCost;
    initialized = true;
  }

  argcheck(nrhs, 1);
  if(mxIsChar(prhs[0])) // call static function or constructor
  {
    convert(prhs[0], memberName);
    switch(memberMap[memberName])
    {
      case MeasureIsConnected:
      {
        static std::string name;

        argcheck(nrhs, 2);
        convert(prhs[1], name);
        convert(tom::Measure::isConnected(name), plhs[0]);
        break;
      }
      case MeasureDescription:
      {
        static std::string name;

        argcheck(nrhs, 2);
        convert(prhs[1], name);
        convert(tom::Measure::description(name), plhs[0]);
        break;
      }
      case MeasureFactory:
      {
        static std::string name;
        static double initialTime;
        static std::string uri;
        static uint32_t numInstances;
        tom::Measure* obj;

        argcheck(nrhs, 4);
        convert(prhs[1], name);
        convert(prhs[2], initialTime);
        convert(prhs[3], uri);
        obj = tom::Measure::create(name, initialTime, uri);
        numInstances = instance.size();
        instance.resize(numInstances+1);
        instance[numInstances] = obj;
        convert(numInstances, plhs[0]);
        break;
      }
      default:
      {
        throw("MeasureBridge: invalid static function call");
      }
    }
  }
  else // call non-static member funciton
  {
    uint32_t handle;

    argcheck(nrhs, 2);
    convert(prhs[0], handle);
    convert(prhs[1], memberName);

    if(handle>=instance.size())
    {
      throw("MeasureBridge: invalid instance");
    }
    switch(memberMap[memberName])
    {
      case undefined:
        throw("MeasureBridge: undefined function call");
        break;

      case refresh:
        static TrajectoryBridge x;
        instance[handle]->refresh(&x);
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
        static uint32_t n;
        argcheck(nrhs, 3);
        convert(prhs[2], n);
        convert(instance[handle]->getTime(n), plhs[0]);
        break;

      case findEdges:
      {
        static uint32_t naMin;
        static uint32_t naMax;
        static uint32_t nbMin;
        static uint32_t nbMax;
        static std::vector<tom::GraphEdge> edgeList;

        argcheck(nrhs, 6);
        convert(prhs[2], naMin);
        convert(prhs[3], naMax);
        convert(prhs[4], nbMin);
        convert(prhs[5], nbMax);
        instance[handle]->findEdges(naMin, naMax, nbMin, nbMax, edgeList);
        convert(edgeList, plhs[0]);
        break;
      }

      case computeEdgeCost:
      {
        static TrajectoryBridge x;
        static tom::GraphEdge graphEdge;
        argcheck(nrhs, 3);
        convert(prhs[2], graphEdge);
        convert(instance[handle]->computeEdgeCost(&x, graphEdge), plhs[0]);
        break;
      }

      default:
      {
        throw("MeasureBridge: invalid member function call");
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
