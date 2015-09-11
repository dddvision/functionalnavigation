#ifndef HIDILINSPACE_H
#define HIDILINSPACE_H

#include <vector>
#include "+hidi/hidi.h"

namespace hidi
{ 
  // Linearly spaced vector.
  //
  // @param[in] a initial value
  // @param[in] b final value
  // @param[in] N number of elements in (a, b)
  // @return      vector of values
  std::vector<double> linspace(const double& a, const double& b, const uint32_t& N)
  {
    uint32_t n;
    std::vector<double> v;
    v.resize(N);
    if(N==1)
    {
      v[0] = (b+a)/2.0;
    }
    else if(N>1)
    {
      for(n = 0; n<N; ++n)
      {
        v[n] = a+(b-a)*static_cast<double>(n)/static_cast<double>(N-1);
      }
    }
    return(v);
  }
}

#endif
