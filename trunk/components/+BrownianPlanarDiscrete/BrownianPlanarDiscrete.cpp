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
    std::vector<double> x;
    std::vector<double> y;
    std::vector<double> a;
    std::vector<double> fx;
    std::vector<double> fy;
    std::vector<double> fa;
    std::vector<uint32_t> px;
    std::vector<uint32_t> py;
    std::vector<uint32_t> pz;
    
  public:
    BrownianPlanar(Time initialTime,std::string uri)
    {
      this.to=static_cast<double>(initialTime);
      this.x.reserve(1024);
      this.y.reserve(1024);
      this.a.reserve(1024);
      this.fx.reserve(1024);
      this.fy.reserve(1024);
      this.fa.reserve(1024);
      this.px.reserve(1024);
      this.py.reserve(1024);
      this.pa.reserve(1024);
      x[0]=0.0;
      y[0]=0.0;
      z[0]=0.0;
      return;
    }
    
    Time updateRate(void) const
    {
      return(static_cast<Time>(0.5));
    }
    
    unsigned numInitialLogical(void) const {return(0);}
    unsigned numInitialUint32(void) const {return(3);}
    unsigned numExtensionLogical(void) const {return(0);}
    unsigned numExtensionUint32(void) const {return(3);}
    
    unsigned numExtensionBlocks(void)
    {
      return(static_cast<unsigned>(dx.size()));
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
          return(this.pxo);
        case 1:
          return(this.pyo);
        case 2:
          return(this.pao);
        default:
          std::cout << "Error: getInitialDiscrete" << std::endl;
          return(this.pxo);
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
  }  
}
