#include <iostream>
#include "DynamicModel.h"

int main()
{ 
  std::cout << "This is an example application of the Trajectory Optimization Manager for " << std::endl
    << "Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer " << std::endl
    << "and a graphical display, and then alternately optimizes and displays " << std::endl
    << "trajectories in an infinite loop. See DemoConfig for options." << std::endl;
  
  tom::DynamicModel* dynamicModel = tom::DynamicModel::create("BrownianPlanar",0.0,"uri");
  std::cout << dynamicModel->numExtensionBlocks() << std::endl;
//  tom::Measure* measure = tom::Measure::create("OpticalFlowOpenCV", "uri");
//  measure->refresh();
  return(0);
}
