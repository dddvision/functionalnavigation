#ifndef HIDIUNIQUE_H
#define HIDIUNIQUE_H

#include <algorithm>
#include <vector>
#include "+hidi/hidi.h"

namespace hidi
{
  // Return shallow copies of unique elements sorted in ascending order.
  template <class T>
  std::vector<T> unique(const std::vector<T>& x)
  {
    std::vector<T> y;
    y = x;
    std::sort(y.begin(), y.end()); // required by unique function
    y.erase(std::unique(y.begin(), y.end()), y.end());
    return(y); // compiler should execute move
  }
}

#endif
