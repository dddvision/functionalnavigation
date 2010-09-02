#ifndef TIMEINTERVAL_H
#define TIMEINTERVAL_H

#include "WorldTime.h"

namespace tom
{
  /**
   * This class represents an interval of time by its upper and lower bounds
   *
   * @param[in,out] first  time lower bound
   * @param[in,out] second time upper bound, WorldTime scalar
   */
  typedef std::pair<WorldTime, WorldTime> TimeInterval;
}

#endif
