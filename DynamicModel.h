#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include <map>
#include <string>
#include <vector>

// define uint32_t if necessary
#ifndef uint32_t
#ifdef _MSC_VER
#if (_MSC_VER < 1300)
typedef unsigned int uint32_t;
#else
typedef unsigned __int32 uint32_t;
#endif
#else
#include <stdint.h>
#endif
#endif

#include "WorldTime.h"
#include "TimeInterval.h"
#include "Trajectory.h"

namespace tommas
{
  class DynamicModel : public Trajectory
  {
  private:
    typedef DynamicModel* (*DynamicModelFactory)(const WorldTime, const std::string);

    DynamicModel(const DynamicModel&){}  

    static std::map<std::string,std::string>* _pDescriptionList(void)
    {
      static std::map<std::string,std::string> descriptionList;
      return &descriptionList;
    }

    static std::map<std::string,DynamicModelFactory>* _pFactoryList(void)
    {
      static std::map<std::string,DynamicModelFactory> factoryList;
      return &factoryList;
    }

  protected:
    DynamicModel(const WorldTime,const std::string){}
    ~DynamicModel(void){}
    
  public:
    static std::string description(const std::string name)
    {
      std::string str="";
      if(_pDescriptionList()->find(name) != _pDescriptionList()->end())
      {
        str=(*_pDescriptionList())[name];
      }
      return str;
    }

    static DynamicModel* factory(const std::string name, const WorldTime initialTime, const std::string uri)
    {
      DynamicModel* obj=NULL;
      if(_pFactoryList()->find(name) != _pFactoryList()->end())
      {
        obj=(*_pFactoryList())[name](initialTime,uri);
      }
      return obj;
    }

    static void associate(const std::string name, const std::string description, const DynamicModelFactory componentFactory)
    {
      (*_pDescriptionList())[name]=description;
      (*_pFactoryList())[name]=componentFactory;
      return;
    }

    virtual uint32_t numInitialLogical(void) const = 0;
    virtual uint32_t numInitialUint32(void) const = 0;
    virtual uint32_t numExtensionLogical(void) const = 0;
    virtual uint32_t numExtensionUint32(void) const = 0;
    
    virtual uint32_t numExtensionBlocks(void) = 0;
    
    virtual bool getInitialLogical(uint32_t) = 0;
    virtual uint32_t getInitialUint32(uint32_t) = 0;
    virtual bool getExtensionLogical(uint32_t,uint32_t) = 0;
    virtual uint32_t getExtensionUint32(uint32_t,uint32_t) = 0;
    virtual void setInitialLogical(uint32_t,bool) = 0;
    virtual void setInitialUint32(uint32_t,uint32_t) = 0;
    virtual void setExtensionLogical(uint32_t,uint32_t,bool) = 0;
    virtual void setExtensionUint32(uint32_t,uint32_t,uint32_t) = 0;

    virtual double computeInitialBlockCost(void) = 0;
    virtual double computeExtensionBlockCost(uint32_t) = 0;

    virtual void extend(void) = 0;
  };
}

#endif
