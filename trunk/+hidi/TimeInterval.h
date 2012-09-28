#ifndef HIDITIMEINTERVAL_H
#define HIDITIMEINTERVAL_H

#include <utility>
#include "hidi.h"

namespace hidi
{
  /**
   * This class represents an interval of time by its upper and lower bounds
   *
   * @param[in,out] first  time lower bound
   * @param[in,out] second time upper bound
   */
  typedef std::pair<double, double> TimeInterval;
}

#endif
