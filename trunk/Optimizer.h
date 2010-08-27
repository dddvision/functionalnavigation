#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include <map>
#include <string>
#include <vector>

#include "DynamicModel.h"
#include "Measure.h"

namespace tommas
{
  class Optimizer
  {
  private:
    Optimizer(const Optimizer&){}

    typedef std::string (*OptimizerDescription)(void);
    static std::map<std::string,OptimizerDescription>* pDescriptionList(void)
    {
      static std::map<std::string,OptimizerDescription> descriptionList;
      return &descriptionList;
    }

    typedef Optimizer* (*OptimizerFactory)(const std::vector<DynamicModel*>&, const std::vector<Measure*>&);
    static std::map<std::string,OptimizerFactory>* pFactoryList(void)
    {
      static std::map<std::string,OptimizerFactory> factoryList;
      return &factoryList;
    }

  protected:
    Optimizer(const std::vector<DynamicModel*>&, const std::vector<Measure*>&){}
    ~Optimizer(void){}
    
  public:
    static void connect(const std::string name, const OptimizerDescription cD, const OptimizerFactory cF)
    {
      if(!((cD==NULL)|(cF==NULL)))
      {
        (*pDescriptionList())[name]=cD;
        (*pFactoryList())[name]=cF;
      }
      return;
    }

    static bool isConnected(const std::string name)
    {
      return(pFactoryList()->find(name) != pFactoryList()->end());
    }

    static std::string description(const std::string name)
    {
      std::string str="";
      if(isConnected(name))
      {
        str=(*pDescriptionList())[name]();
      }
      return(str);
    }

    static Optimizer* factory(const std::string name,
      std::vector<DynamicModel*> &dynamicModel, std::vector<Measure*> &measure)
    {
      Optimizer* obj=NULL;
      if(isConnected(name))
      {
        obj=(*pFactoryList())[name](dynamicModel,measure);
      }
      else
      {
        throw("Optimizer is not connected to the requested component");
      }
      return(obj);
    }

    virtual unsigned numResults(void) = 0;
    virtual DynamicModel* getTrajectory(const unsigned) = 0;
    virtual double getCost(const unsigned) = 0;
    virtual void step(void) = 0;
  };
}

#endif
