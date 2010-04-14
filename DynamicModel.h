#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include <map>
#include <string>
#include <vector>
#include <iostream>

#include "Time.h"
#include "ParameterBlock.h"
#include "Trajectory.h"

namespace tommas
{
  class DynamicModel;
  typedef DynamicModel* (*DynamicModelFactory)(Time,std::string);
  extern std::map<const std::string,DynamicModelFactory> dynamicModelList;
  
  class DynamicModel : public Trajectory
  {
  private:
    DynamicModel(const DynamicModel&){}  
    
  protected:
    DynamicModel(Time,std::string){}
    ~DynamicModel(void){} 
    
  public:
    virtual unsigned numInitialLogical(void) const = 0;
    virtual unsigned numInitialUint32(void) const = 0;
    virtual unsigned numExtensionLogical(void) const = 0;
    virtual unsigned numExtensionUint32(void) const = 0;
    virtual Time updateRate(void) = 0;
    virtual double computeInitialBlockCost(const ParameterBlock*) = 0;
    virtual ParameterBlock* getInitialBlock(void) = 0;
    virtual void setInitialBlock(const ParameterBlock*) = 0;
    virtual double computeExtensionBlockCost(const ParameterBlock*) = 0;
    virtual unsigned numExtensionBlocks(void) = 0;
    virtual std::vector<ParameterBlock*> getExtensionBlocks(const std::vector<unsigned>&) = 0;
    virtual void setExtensionBlocks(const std::vector<unsigned>&,const std::vector<ParameterBlock*>&) = 0;
    virtual void appendExtensionBlocks(const std::vector<unsigned>&,const std::vector<ParameterBlock*>&) = 0;
    
  public:
    static std::string frameworkClass(void) { return std::string("DynamicModel"); }
    static DynamicModel* factory(std::string dynamicModelName,Time initialTime,std::string uri)
    {
      if(dynamicModelList.find(dynamicModelName) == dynamicModelList.end())
      { 
        std::cerr << dynamicModelName << " not found in dynamic model list" << std::endl;
        return NULL;
      }
      else { return dynamicModelList[dynamicModelName](initialTime,uri); }
    }
  };
}

#endif
