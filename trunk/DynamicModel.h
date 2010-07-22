#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include <map>
#include <string>
#include <vector>

// define uint32_t
#ifdef _MSC_VER
#if (_MSC_VER < 1300)
typedef unsigned int uint32_t;
#else
typedef unsigned __int32 uint32_t;
#endif
#else
#include <stdint.h>
#endif

#include "WorldTime.h"
#include "TimeInterval.h"
#include "Trajectory.h"

namespace tommas
{
  class DynamicModel;
  typedef DynamicModel* (*DynamicModelFactory)(const WorldTime,const std::string);
  extern std::map<const std::string,DynamicModelFactory> dynamicModelList;
  
  class DynamicModel : public Trajectory
  {
  private:
    DynamicModel(const DynamicModel&){}  

  protected:
    DynamicModel(const WorldTime,const std::string){}
    ~DynamicModel(void){}
    
  public:
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

    virtual void extend(void) = 0;
    
  public:
    static std::string frameworkClass(void) { return std::string("DynamicModel"); }
    static DynamicModel* factory(const std::string dynamicModelName,const WorldTime initialTime,const std::string uri)
    {
      DynamicModel* obj=NULL;
      if(dynamicModelList.find(dynamicModelName) != dynamicModelList.end())
      {
        obj=dynamicModelList[dynamicModelName](initialTime,uri);
      }
      return obj;
    }
  };
}

#endif
