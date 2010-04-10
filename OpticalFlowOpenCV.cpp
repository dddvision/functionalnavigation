#include "tommas.h"

namespace tommas
{
  class OpticalFlowOpenCV : public Measure
  {
  public:
    OpticalFlowOpenCV(std::string uri) : Measure(uri)
    {
      std::cout << std::endl << "OpticalFlowOpenCV::OpticalFlowOpenCV" << std::endl;
    }

    EdgeList findEdges(const NodeIndex,const NodeIndex)
    {
      EdgeList edge(1);
      return(edge);
    }

    Cost computeEdgeCost(const Trajectory&,const NodeIndex,const NodeIndex)
    {
      Cost cost=0.0;
      return(cost);
    }

    void refresh(void) { std::cout << std::endl << "OpticalFlowOpenCV::refresh" << std::endl; return; };

    bool hasData(void) { return(true); };

    NodeIndex first(void) { return(0); };

    NodeIndex last(void) { return(0); };

    Time getTime(NodeIndex) { return(0.0); };
  };
  
  Measure* OpticalFlowOpenCVFactory(std::string uri) { return(new OpticalFlowOpenCV(uri)); }
}
