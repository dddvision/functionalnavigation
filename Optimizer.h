#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include <map>
#include <string>
#include <vector>

#include "DynamicModel.h"
#include "Measure.h"

namespace tommas
{
  class Optimizer;
  typedef Optimizer* (*OptimizerFactory)(std::vector<DynamicModel&>&,std::vector<Measure&>&);
  extern std::map<const std::string,OptimizerFactory> optimizerList;
  
  class Optimizer
  {
  private:
    Optimizer(const Optimizer&){}
    
  protected:
    Optimizer(std::string,std::string,std::string){}
    ~Optimizer(void){}

  public:
    virtual unsigned numResults(void) = 0;
    virtual DynamicModel* getTrajectory(const unsigned) = 0;
    virtual double getCost(const unsigned) = 0;
    virtual void step(void) = 0;
    
    static Optimizer* factory(std::string optimizerName,
      std::vector<DynamicModel&> &dynamicModel, std::vector<Measure&> &measure)
    {
      Optimizer* obj;
      if(optimizerList.find(optimizerName) != optimizerList.end())
      {
        obj=optimizerList[optimizerName](dynamicModel,measure);
      }
      return obj;
    }
  };
}

#endif
