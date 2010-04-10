#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include "tommas.h"

namespace tommas
{
  class Optimizer;
  typedef Optimizer* (*OptimizerFactory)(std::string,std::vector<std::string>,std::string);
  extern std::map<const std::string,OptimizerFactory> optimizerList;
  
  class Optimizer
  {
  protected:
    Optimizer(std::string,std::string,std::string){}

  public:
    virtual void getResults(std::vector<Trajectory*>*,std::vector<Cost>*) = 0;
    virtual void step(void) = 0;
    
    static std::string frameworkClass(void) { return std::string("Optimizer"); }
    static Optimizer* factory(std::string optimizerName,std::string dynamicModelName,
      std::vector<std::string> measureNames,std::string uri)
    {
      return optimizerList[optimizerName](dynamicModelName,measureNames,uri);
    }
  };
}

#endif
