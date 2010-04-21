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

  void RegisterComponents(void)
  {
    extern Measure* OpticalFlowOpenCVFactory(std::string);
    measureList["OpticalFlowOpenCV"] = OpticalFlowOpenCVFactory;
    return;
  }
}

using namespace tommas;

int main()
{ 
  std::cout << "This is an example application of the Trajectory Optimization Manager for " << std::endl
    << "Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer " << std::endl
    << "and a graphical display, and then alternately optimizes and displays " << std::endl
    << "trajectories in an infinite loop. See demoConfig for options." << std::endl;
  RegisterComponents();
  Measure* measure = Measure::factory("OpticalFlowOpenCV", "uri");
  measure->refresh();
  return 0;
}
