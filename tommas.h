#ifndef TOMMAS_H
#define TOMMAS_H

#include "DataContainer.h"
#include "DynamicModel.h"
#include "Measure.h"
#include "Optimizer.h"

namespace tommas
{
  std::map<std::string,DataContainerFactory> dataContainerList;
  std::map<const std::string,DynamicModelFactory> dynamicModelList;
  std::map<std::string,MeasureFactory> measureList;
  std::map<const std::string,OptimizerFactory> optimizerList;

  // register all C++ components here 
  void tommas(void)
  {
//    extern Measure* OpticalFlowOpenCVFactory(const std::string);
//    measureList["OpticalFlowOpenCV"] = OpticalFlowOpenCVFactory;

    extern DynamicModel* BrownianPlanarFactory(const WorldTime initialTime, const std::string);
    dynamicModelList["BrownianPlanar"] = BrownianPlanarFactory;
    return;
  }
}

#endif
