#include <iostream>
#include "Measure.h"

// namespace tommas
// {
//   class OpticalFlowOpenCV : public Measure
//   {
//   private:
//     OpticalFlowOpenCV(std::string uri) : Measure(uri)
//     {
//       std::cout << std::endl << "OpticalFlowOpenCV::OpticalFlowOpenCV" << std::endl;
//     }
//   
//   public:
//     std::list<Edge> findEdges(const unsigned,const unsigned)
//     {
//       std::list<Edge> edge(1);
//       return(edge);
//     }
// 
//     double computeEdgeCost(const Trajectory&,const Edge)
//     {
//       double cost=0.0;
//       return(cost);
//     }
// 
//     void refresh(void) { std::cout << std::endl << "OpticalFlowOpenCV::refresh" << std::endl; return; };
// 
//     bool hasData(void) { return(true); };
// 
//     unsigned first(void) { return(0); };
// 
//     unsigned last(void) { return(0); };
// 
//     Time getTime(unsigned k) { return(0.0); };
//   };
//   
//   Measure* OpticalFlowOpenCVFactory(std::string uri) { return(new OpticalFlowOpenCV(uri)); }
// }
