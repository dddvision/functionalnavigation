#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include "tommas.h"

namespace tommas
{
  class DynamicModel;
  typedef DynamicModel* (*DynamicModelFactory)(Time,std::string);
  extern std::map<const std::string,DynamicModelFactory> dynamicModelList;
  
  typedef double Cost;
  typedef unsigned int BlockIndex;
  
  class Block
  {
  public:
    virtual std::vector<bool>& Logical(void) = 0;
    virtual std::vector<uint32_t>& Uint32(void) = 0;
  };
  
  class BlockDescription
  {
  public:
    virtual uint32_t numLogical(void) const = 0;
    virtual uint32_t numUint32(void) const = 0;    
  };
  
  class DynamicModel : public Trajectory
  {
  private:
    DynamicModel(const DynamicModel&){}  
    
  protected:
    DynamicModel(Time,std::string){}
    ~DynamicModel(void){} 
    
  public:
    virtual BlockDescription* initialBlockDescription(void) = 0;
    virtual BlockDescription* extensionBlockDescription(void) = 0;
    virtual Time updateRate(void) = 0;
    virtual Cost computeInitialBlockCost(const Block*) = 0;
    virtual void setInitialBlock(const Block*) = 0;
    virtual Block* getInitialBlock(void) = 0;
    virtual Cost computeExtensionBlockCost(const Block*) = 0;
    virtual BlockIndex numExtensionBlocks(void) = 0;
    virtual void setExtensionBlocks(const std::vector<BlockIndex>&,const std::vector<Block*>&) = 0;
    virtual std::vector<Block*>& getExtensionBlocks(const std::vector<BlockIndex>&) = 0;
    virtual void appendExtensionBlocks(const std::vector<BlockIndex>&,const std::vector<Block*>&) = 0;
    
  public:
    static std::string frameworkClass(void) { return std::string("DynamicModel"); }
    static DynamicModel* factory(std::string dynamicModelName,Time initialTime,std::string uri)
      { return dynamicModelList[dynamicModelName](initialTime,uri); }
  };
}

#endif
