#ifndef HIDIFIND_H
#define HIDIFIND_H

#include <vector>
#include "+hidi/hidi.h"

namespace hidi
{
  // Return indices corresponding to elements equal to the specified value.
  template <class T>
  std::vector<uint32_t> find(const std::vector<T>& x, const T& v)
  {
    uint32_t n;
    uint32_t N;
    std::vector<uint32_t> y;
    N = x.size();
    y.reserve(N); // not resize
    for(n = 0; n<N; ++n)
    {
      if(x[n]==v)
      {
        y.push_back(n);
      }
    }
    return(y); // compiler should execute move
  }
}

#endif
