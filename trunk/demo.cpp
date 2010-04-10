#include "tommas.h"

using namespace tommas;

int main()
{ 
  std::cout << "This is an example application of the Trajectory Optimization Manager for " << std::endl
    << "Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer " << std::endl
    << "and a graphical display, and then alternately optimizes and displays " << std::endl
    << "trajectories in an infinite loop. See demoConfig for options." << std::endl;
  TommasConfig();
  Measure* measure = Measure::factory("OpticalFlowOpenCV", "uri");
  measure->refresh();
  return 0;
}
