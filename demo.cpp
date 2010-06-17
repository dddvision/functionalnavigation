#include <iostream>
#include "tommas.h"

int main()
{ 
  std::cout << "This is an example application of the Trajectory Optimization Manager for " << std::endl
    << "Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer " << std::endl
    << "and a graphical display, and then alternately optimizes and displays " << std::endl
    << "trajectories in an infinite loop. See DemoConfig for options." << std::endl;
  
  tommas::tommas();
  tommas::DynamicModel* dynamicModel = tommas::DynamicModel::factory("BrownianPlanar",0.0,"uri");
  std::cout << dynamicModel->numExtensionBlocks() << std::endl;
//  tommas::Measure* measure = tommas::Measure::factory("OpticalFlowOpenCV", "uri");
//  measure->refresh();
  return(0);
}
