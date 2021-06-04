// Copyright 2011 Scientific Systems Company Inc., New BSD License
#include "hidiBridge.h"
#include "SensorPackageBridge.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
  hidi::mexFunctionWithCatch(hidi::SensorPackageBridge::SensorPackageBridge, nlhs, plhs, nrhs, prhs);
}
