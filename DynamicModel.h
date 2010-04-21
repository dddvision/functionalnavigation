#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include <map>
#include <string>
#include <vector>
#include <iostream>
#include <stdint.h>

#include "Time.h"
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
    virtual Time updateRate(void) const = 0;
    
    virtual unsigned numInitialLogical(void) const = 0;
    virtual unsigned numInitialUint32(void) const = 0;
    virtual unsigned numExtensionLogical(void) const = 0;
    virtual unsigned numExtensionUint32(void) const = 0;
    
    virtual unsigned numExtensionBlocks(void) = 0;
    
    virtual bool getInitialLogical(unsigned) = 0;
    virtual uint32_t getInitialUint32(unsigned) = 0;
    virtual bool getExtensionLogical(unsigned,unsigned) = 0;
    virtual uint32_t getExtensionUint32(unsigned,unsigned) = 0;
    virtual void setInitialLogical(unsigned,bool) = 0;
    virtual void setInitialUint32(unsigned,uint32_t) = 0;
    virtual void setExtensionLogical(unsigned,unsigned,bool) = 0;
    virtual void setExtensionUint32(unsigned,unsigned,uint32_t) = 0;

    virtual double computeInitialBlockCost(void) = 0;
    virtual double computeExtensionBlockCost(unsigned) = 0;

    virtual void extend(unsigned) = 0;
    
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
