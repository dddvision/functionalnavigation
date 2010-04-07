#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include "tommas.h"

namespace tommas
{
  class DynamicModel : public Trajectory
  {
  public:
    static const std::string frameworkClass="DynamicModel";

    // need to work out issue of sizing the InitialBlock type based on the derived class (see Tony's dynamic model code)
    static DynamicModel* factory(const std::string dynamicModelName,Time initialTime,InitialBlock initialBlock,std::string uri)
      { return dynamicModelList[dynamicModelName](initialTime,initialBlock,uri); }
  
  protected:
    DynamicModel(InitialTime,InitialBlock,std::string);
  
  public:
    static InitialBlockDescription initialBlockDescription;
    static ExtensionBlockDescription extensionBlockDescription;
    static UpdateRate updateRate;

    virtual Cost computeInitialBlockCost(const InitialBlock);
    virtual void setInitialBlock(const InitialBlock);
    virtual InitialBlock getInitialBlock(void);
    virtual Cost computeExtensionBlockCost(const ExtensionBlock);
    virtual BlockIndex numExtensionBlocks(void);
    virtual setExtensionBlocks(const std::vector<BlockIndex>,const std::vector<ExtensionBlock>);
    virtual std::vector<ExtensionBlock> getExtensionBlocks(const std::vector<BlockIndex>);
    virtual appendExtensionBlocks(const std::vector<BlockIndex>);
  };
}

#endif

