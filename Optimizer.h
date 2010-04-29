#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include <map>
#include <string>
#include <vector>

#include "Trajectory.h"

namespace tommas
{
  class Optimizer;
  typedef Optimizer* (*OptimizerFactory)(std::string,std::vector<std::string>,std::string);
  extern std::map<const std::string,OptimizerFactory> optimizerList;
  
  class Optimizer
  {
  private:
    Optimizer(const Optimizer&){}
    
  protected:
    Optimizer(std::string,std::string,std::string){}
    ~Optimizer(void){}

  public:
    virtual void getResults(std::vector<Trajectory*>*,std::vector<double>*) = 0;
    virtual void step(void) = 0;
    
    static std::string frameworkClass(void) { return std::string("Optimizer"); }
    static Optimizer* factory(std::string optimizerName,std::string dynamicModelName,
      std::vector<std::string> measureNames,std::string uri)
    {
      assert(optimizerList.find(optimizerName) != optimizerList.end());
      return optimizerList[optimizerName](dynamicModelName,measureNames,uri);
    }
  };
}

#endif
