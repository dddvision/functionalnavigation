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
    DynamicModel(const DynamicModel&){}

    typedef std::string (*DynamicModelDescription)(void);
    static std::map<std::string,DynamicModelDescription>* pDescriptionList(void)
    {
      static std::map<std::string,DynamicModelDescription> descriptionList;
      return &descriptionList;
    }

    typedef DynamicModel* (*DynamicModelFactory)(const WorldTime, const std::string);
    static std::map<std::string,DynamicModelFactory>* pFactoryList(void)
    {
      static std::map<std::string,DynamicModelFactory> factoryList;
      return &factoryList;
    }

  protected:
    DynamicModel(const WorldTime,const std::string){}
    ~DynamicModel(void){}

    static void connect(const std::string name, const DynamicModelDescription cD, const DynamicModelFactory cF)
    {
      if(!((cD==NULL)|(cF==NULL)))
      {
        (*pDescriptionList())[name]=cD;
        (*pFactoryList())[name]=cF;
      }
      return;
    }    

  public:
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

    static DynamicModel* factory(const std::string name, const WorldTime initialTime, const std::string uri)
    {
      DynamicModel* obj=NULL;
      if(isConnected(name))
      {
        obj=(*pFactoryList())[name](initialTime,uri);
      }
      else
      {
        throw("DynamicModel is not connected to the requested component");
      }
      return(obj);
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
