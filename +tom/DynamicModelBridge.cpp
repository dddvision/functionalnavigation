#include "mex.h"
#include "DynamicModel.h"

enum DynamicModelMember
{
    undefined,
    DynamicModelIsConnected,
    DynamicModelDescription,
    DynamicModelFactory,
    domain,
    evaluate,
    tangent,
    numInitial,
    numExtension,
    numBlocks,
    getInitial,
    getExtension,
    setInitial,
    setExtension,
    computeInitialCost,
    computeExtensionCost,
    extend,
    copy
};

void argcheck(int& narg, int n)
{
  if(n>narg)
  {
    throw("DynamicModelBridge: too few input arguments");
  }
  return;
}

void convert(const mxArray*& array, double& value)
{
  if(mxGetClassID(array)!=mxDOUBLE_CLASS)
  {
    throw("DynamicModelBridge: array must be double");
  }
  value = (*static_cast<double*>(mxGetData(array)));
  return;
}

void convert(const mxArray*& array, uint32_t& value)
{
  if(mxGetClassID(array)!=mxUINT32_CLASS)
  {
    throw("DynamicModelBridge: array must be uint32");
  }
  value = (*static_cast<uint32_t*>(mxGetData(array)));
  return;
}

void convert(const mxArray*& array, std::string& cppString)
{
  unsigned N = mxGetNumberOfElements(array)+1; // add one for terminating character
  char *cString = new char[N];
  if(mxGetClassID(array)!=mxCHAR_CLASS)
  {
    throw("DynamicModelBridge: array must be char");
  }
  mxGetString(array, cString, N);
  cppString = cString;
  delete[] cString;
  return;
}

void convert(const mxArray*& array, std::vector<tom::WorldTime>& cppTime)
{
  double* mTime;
  unsigned n;
  unsigned N = mxGetNumberOfElements(array);
  mTime = mxGetPr(array);
  cppTime.resize(N);
  for(n = 0; n<N; ++n)
  {
    cppTime[n] = mTime[n];
  }
  return;
}

void convert(const double& value, mxArray*& array)
{
  array = mxCreateDoubleScalar(value);
  return;
}

void convert(const uint32_t& value, mxArray*& array)
{
  array = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
  (*static_cast<uint32_t*>(mxGetData(array))) = value;
  return;
}

void convert(const bool& value, mxArray*& array)
{
  array = mxCreateLogicalScalar(value);
  return;
}

void convert(std::string str, mxArray*& array)
{
  array = mxCreateString(str.c_str());
  return;
}

void convert(const tom::TimeInterval& timeInterval, mxArray*& array)
{
  mxArray* first;
  mxArray* second;
  mxArray* firstWT;
  mxArray* secondWT;
  mxArray* interval[2];

  first = mxCreateDoubleScalar(timeInterval.first);
  second = mxCreateDoubleScalar(timeInterval.second);
  mexCallMATLAB(1, &firstWT, 1, &first, "tom.WorldTime");
  mexCallMATLAB(1, &secondWT, 1, &second, "tom.WorldTime");
  interval[0] = firstWT;
  interval[1] = secondWT;
  mexCallMATLAB(1, &array, 2, interval, "tom.TimeInterval");
  mxDestroyArray(first);
  mxDestroyArray(second);
  mxDestroyArray(firstWT);
  mxDestroyArray(secondWT);
  return;
}

void convert(const std::vector<tom::Pose>& pose, const mxArray*& source, mxArray*& array)
{
  mxArray* p;
  mxArray* q;
  double* pp;
  double* pq;
  unsigned n;
  unsigned N = pose.size();
  array = mxDuplicateArray(source);
  for(n = 0; n<N; ++n)
  {
    p = mxCreateDoubleMatrix(3, 1, mxREAL);
    q = mxCreateDoubleMatrix(4, 1, mxREAL);
    pp = mxGetPr(p);
    pq = mxGetPr(q);
    pp[0] = pose[n].p[0];
    pp[1] = pose[n].p[1];
    pp[2] = pose[n].p[2];
    pq[0] = pose[n].q[0];
    pq[1] = pose[n].q[1];
    pq[2] = pose[n].q[2];
    pq[3] = pose[n].q[3];
    mxSetProperty(array, n, "p", p);
    mxSetProperty(array, n, "q", q);
  }
  return;
}

void convert(const std::vector<tom::TangentPose>& tangentPose, const mxArray*& source, mxArray*& array)
{
  mxArray* p;
  mxArray* q;
  mxArray* r;
  mxArray* s;
  double* pp;
  double* pq;
  double* pr;
  double* ps;
  unsigned n;
  unsigned N = tangentPose.size();
  array = mxDuplicateArray(source);
  for(n = 0; n<N; ++n)
  {
    p = mxCreateDoubleMatrix(3, 1, mxREAL);
    q = mxCreateDoubleMatrix(4, 1, mxREAL);
    r = mxCreateDoubleMatrix(3, 1, mxREAL);
    s = mxCreateDoubleMatrix(3, 1, mxREAL);
    pp = mxGetPr(p);
    pq = mxGetPr(q);
    pr = mxGetPr(r);
    ps = mxGetPr(s);
    pp[0] = tangentPose[n].p[0];
    pp[1] = tangentPose[n].p[1];
    pp[2] = tangentPose[n].p[2];
    pq[0] = tangentPose[n].q[0];
    pq[1] = tangentPose[n].q[1];
    pq[2] = tangentPose[n].q[2];
    pq[3] = tangentPose[n].q[3];
    pr[0] = tangentPose[n].r[0];
    pr[1] = tangentPose[n].r[1];
    pr[2] = tangentPose[n].r[2];
    ps[0] = tangentPose[n].s[0];
    ps[1] = tangentPose[n].s[1];
    ps[2] = tangentPose[n].s[2];
    mxSetProperty(array, n, "p", p);
    mxSetProperty(array, n, "q", q);
    mxSetProperty(array, n, "r", r);
    mxSetProperty(array, n, "s", s);
  }
  return;
}

void safeMexFunction(int& nlhs, mxArray**& plhs, int& nrhs, const mxArray**& prhs)
{
  static std::map<std::string, DynamicModelMember> memberMap;
  static std::vector<tom::DynamicModel*> instance;
  static bool initialized = false;
  static std::string memberName;

  if(!initialized)
  {
    memberMap["DynamicModelIsConnected"] = DynamicModelIsConnected;
    memberMap["DynamicModelDescription"] = DynamicModelDescription;
    memberMap["DynamicModelFactory"] = DynamicModelFactory;
    memberMap["domain"] = domain;
    memberMap["evaluate"] = evaluate;
    memberMap["tangent"] = tangent;
    memberMap["numInitial"] = numInitial;
    memberMap["numExtension"] = numExtension;
    memberMap["numBlocks"] = numBlocks;
    memberMap["getInitial"] = getInitial;
    memberMap["getExtension"] = getExtension;
    memberMap["setInitial"] = setInitial;
    memberMap["setExtension"] = setExtension;
    memberMap["computeInitialCost"] = computeInitialCost;
    memberMap["computeExtensionCost"] = computeExtensionCost;
    memberMap["extend"] = extend;
    memberMap["copy"] = copy;
    initialized = true;
  }

  argcheck(nrhs, 1);
  if(mxIsChar(prhs[0])) // call static function or constructor
  {
    convert(prhs[0], memberName);
    switch(memberMap[memberName])
    {
      case DynamicModelIsConnected:
      {
        static std::string name;

        argcheck(nrhs, 2);
        convert(prhs[1], name);
        convert(tom::DynamicModel::isConnected(name), plhs[0]);
        break;
      }
      case DynamicModelDescription:
      {
        static std::string name;

        argcheck(nrhs, 2);
        convert(prhs[1], name);
        convert(tom::DynamicModel::description(name), plhs[0]);
        break;
      }
      case DynamicModelFactory:
      {
        static std::string name;
        static tom::WorldTime initialTime;
        static std::string uri;
        static uint32_t numInstances;
        tom::DynamicModel* obj;
        
        argcheck(nrhs, 4);
        convert(prhs[1], name);
        convert(prhs[2], initialTime);
        convert(prhs[3], uri);
        obj = tom::DynamicModel::create(name, initialTime, uri);
        numInstances = instance.size();
        instance.resize(numInstances+1);
        instance[numInstances] = obj;
        convert(numInstances, plhs[0]);
        break;
      }
      default:
      {
        throw("DynamicModelBridge: invalid static function call");
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
      throw("DynamicModelBridge: invalid instance");
    }
    switch(memberMap[memberName])
    {
      case undefined:
        throw("DynamicModelBridge: undefined function call");
        break;

      case domain:
        convert(instance[handle]->domain(), plhs[0]);
        break;

      case evaluate:
      {
        static std::vector<tom::WorldTime> time;
        static std::vector<tom::Pose> pose;
        argcheck(nrhs, 4);
        convert(prhs[3], time);
        instance[handle]->evaluate(time, pose);
        convert(pose, prhs[2], plhs[0]);
        break;
      }

      case tangent:
      {
        static std::vector<tom::WorldTime> time;
        static std::vector<tom::TangentPose> tangentPose;
        argcheck(nrhs, 4);
        convert(prhs[3], time);
        instance[handle]->tangent(time, tangentPose);
        convert(tangentPose, prhs[2], plhs[0]);
        break;
      }

      case numInitial:
        convert(instance[handle]->numInitial(), plhs[0]);
        break;

      case numExtension:
        convert(instance[handle]->numExtension(), plhs[0]);
        break;

      case numBlocks:
        convert(instance[handle]->numBlocks(), plhs[0]);
        break;

      case getInitial:
      {
        static uint32_t p;
        argcheck(nrhs, 3);
        convert(prhs[2], p);
        convert(instance[handle]->getInitial(p), plhs[0]);
        break;
      }

      case getExtension:
      {
        static uint32_t b;
        static uint32_t p;
        argcheck(nrhs, 4);
        convert(prhs[2], b);
        convert(prhs[3], p);
        convert(instance[handle]->getExtension(b, p), plhs[0]);
        break;
      }

      case setInitial:
      {
        static uint32_t p;
        static uint32_t v;
        argcheck(nrhs, 4);
        convert(prhs[2], p);
        convert(prhs[3], v);
        instance[handle]->setInitial(p, v);
        break;
      }

      case setExtension:
      {
        static uint32_t b;
        static uint32_t p;
        static uint32_t v;
        argcheck(nrhs, 5);
        convert(prhs[2], b);
        convert(prhs[3], p);
        convert(prhs[4], v);
        instance[handle]->setExtension(b, p, v);
        break;
      }

      case computeInitialCost:
        convert(instance[handle]->computeInitialCost(), plhs[0]);
        break;

      case computeExtensionCost:
      {
        static uint32_t b;
        argcheck(nrhs, 3);
        convert(prhs[2], b);
        convert(instance[handle]->computeExtensionCost(b), plhs[0]);
        break;
      }

      case extend:
      {
        instance[handle]->extend();
        break;
      }
      
      case copy:
      {
        static uint32_t numInstances;
        tom::DynamicModel* obj;
        numInstances = instance.size();      
        obj = instance[handle]->copy();
        instance.resize(numInstances+1);
        instance[numInstances] = obj;
        convert(numInstances, plhs[0]);
        break;
      }

      default:
      {
        throw("DynamicModelBridge: invalid member function call");
      }
    }
  }
  return;
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
    mexErrMsgTxt("DynamicModelBridge: unhandled exception");
  }
  return;
}
