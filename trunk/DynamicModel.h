#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include "tommas.h"

namespace tommas
{
  typedef double Cost;
  typedef unsigned int BlockIndex;
  
  // need to modify all of these types (see Tony's dynamic model code)
  typedef unsigned int InitialBlock;
  typedef unsigned int InitialBlockDescription;
  typedef unsigned int ExtensionBlock;
  typedef unsigned int ExtensionBlockDescription;
  typedef unsigned int UpdateRate;
  
  class DynamicModel;
  typedef DynamicModel* (*DynamicModelFactory)(Time,InitialBlock,std::string);
  extern std::map<const std::string,DynamicModelFactory> dynamicModelList;

  class DynamicModel : public Trajectory
  {
  public:
    static std::string frameworkClass(void) { return std::string("DynamicModel"); }
    static DynamicModel* factory(std::string dynamicModelName,Time initialTime,InitialBlock initialBlock,std::string uri)
      { return dynamicModelList[dynamicModelName](initialTime,initialBlock,uri); }
  
  protected:
    DynamicModel(Time,InitialBlock,std::string){}
  
  public:
    static InitialBlockDescription initialBlockDescription;
    static ExtensionBlockDescription extensionBlockDescription;
    static UpdateRate updateRate;

    virtual Cost computeInitialBlockCost(const InitialBlock) = 0;
    virtual void setInitialBlock(const InitialBlock) = 0;
    virtual InitialBlock getInitialBlock(void) = 0;
    virtual Cost computeExtensionBlockCost(const ExtensionBlock) = 0;
    virtual BlockIndex numExtensionBlocks(void) = 0;
    virtual void setExtensionBlocks(const std::vector<BlockIndex>,const std::vector<ExtensionBlock>) = 0;
    virtual std::vector<ExtensionBlock> getExtensionBlocks(const std::vector<BlockIndex>) = 0;
    virtual void appendExtensionBlocks(const std::vector<BlockIndex>) = 0;
  };
}

#endif
