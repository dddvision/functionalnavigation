#include <vector>
#include <iostream>
#include <stdint.h>

#include "DynamicModel.h" 

namespace tommas
{
  class BrownianPlanarDiscrete : public DynamicModel
  {
  private:
    double to;
    uint32_t pxo;
    uint32_t pyo;
    uint32_t pao;
    std::vector<uint32_t> px;
    std::vector<uint32_t> py;
    std::vector<uint32_t> pa;
    std::vector<double> x;
    std::vector<double> y;
    std::vector<double> a;

  public:
    BrownianPlanarDiscrete(GPSTime initialTime,std::string uri) : DynamicModel(initialTime,uri)
    {
      to=static_cast<double>(initialTime);
      pxo=static_cast<uint32_t>(0);
      pyo=static_cast<uint32_t>(0);
      pao=static_cast<uint32_t>(0);
      px.reserve(1024);
      py.reserve(1024);
      pa.reserve(1024);
      px.clear();
      py.clear();
      pa.clear();
      x.reserve(1024);
      y.reserve(1024);
      a.reserve(1024);
      x[0]=0.0;
      y[0]=0.0;
      a[0]=0.0;
      return;
    }
    
    GPSTime updateRate(void) const
    {
      return(static_cast<GPSTime>(0.5));
    }
    
    unsigned numInitialLogical(void) const {return(0);}
    unsigned numInitialUint32(void) const {return(3);}
    unsigned numExtensionLogical(void) const {return(0);}
    unsigned numExtensionUint32(void) const {return(3);}
    
    unsigned numExtensionBlocks(void)
    {
      return(static_cast<unsigned>(px.size()));
    }
    
    bool getInitialLogical(unsigned parameterIndex)
    {
      std::cout << "Error: getInitialLogical" << std::endl;
      return(false);
    }
    
    uint32_t getInitialUint32(unsigned parameterIndex)
    {
      switch(parameterIndex)
      {
        case 0:
          return(pxo);
        case 1:
          return(pyo);
        case 2:
          return(pao);
        default:
          std::cout << "Error: getInitialDiscrete" << std::endl;
          return(pxo);
      }
    }
    
    bool getExtensionLogical(unsigned blockIndex, unsigned parameterIndex)
    {
      std::cout << "Error: getExtensionLogical" << std::endl;
      return(false);
    }
    
    
    uint32_t getExtensionUint32(unsigned,unsigned);
    void setInitialLogical(unsigned,bool);
    void setInitialUint32(unsigned,uint32_t);
    void setExtensionLogical(unsigned,unsigned,bool);
    void setExtensionUint32(unsigned,unsigned,uint32_t);

    double computeInitialBlockCost(void);
    double computeExtensionBlockCost(unsigned);

    void extend(unsigned);
  };
}