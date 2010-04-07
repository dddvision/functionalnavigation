#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include "tommas.h"
#include "Trajectory.h"

namespace tommas
{
  class Optimizer
  {
  public:
    static const std::string frameworkClass="Optimizer";
    static Optimizer* factory(const std::string optimizerName,Objective* objective)
      { return optimizerList[optimizerName](objective); }

  protected:
    Optimizer(Objective*);

  public:
    virtual void getResults(std::vector<Trajectory*>*,std::vector<Cost>*);
    virtual void step(void);
  };
}

#endif

