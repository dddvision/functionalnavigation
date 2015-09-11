#ifndef HIDIANY_H
#define HIDIANY_H

#include <vector>
#include "+hidi/hidi.h"

namespace hidi
{
  // Evaluate whether any element is true.
  template <class T>
  bool any(const std::vector<T>& x)
  {
    uint32_t n;
    for(n = 0; n<x.size(); ++n)
    {
      if(x[n])
      {
        return(true);
      }
    }
    return(false);
  }
}

#endif
