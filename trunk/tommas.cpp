#include "tommas.h"

namespace tommas
{
  std::map<std::string,DataContainerFactory> dataContainerList;
  std::map<const std::string,DynamicModelFactory> dynamicModelList;
  std::map<std::string,MeasureFactory> measureList;
  std::map<const std::string,OptimizerFactory> optimizerList;
  
  void TommasConfig(void)
  {
    extern Measure* OpticalFlowOpenCVFactory(std::string);
    measureList["OpticalFlowOpenCV"] = OpticalFlowOpenCVFactory;
    return;
  }
}
