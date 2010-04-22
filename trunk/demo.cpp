#include <iostream>
#include <map>

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

int main()
{ 
  std::cout << "This is an example application of the Trajectory Optimization Manager for " << std::endl
    << "Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer " << std::endl
    << "and a graphical display, and then alternately optimizes and displays " << std::endl
    << "trajectories in an infinite loop. See DemoConfig for options." << std::endl;
  
  tommas::RegisterComponents();
  
  tommas::Measure* measure = tommas::Measure::factory("OpticalFlowOpenCV", "uri");
  measure->refresh();
  return(0);
}
