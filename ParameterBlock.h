#ifndef PARAMETERBLOCK_H
#define PARAMETERBLOCK_H

#include <stdint.h>

namespace tommas
{
  class ParameterBlock
  {
  public:
    bool* logical;
    uint32_t* uint32;
  };
}

#endif
