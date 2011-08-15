#ifndef GRAPHEDGE_H
#define GRAPHEDGE_H

// define uint32_t if necessary
#ifndef uint32_t
#ifdef _MSC_VER
#if (_MSC_VER < 1300)
typedef unsigned int uint32_t;
#else
typedef unsigned __int32 uint32_t;
#endif
#else
#include <stdint.h>
#endif
#endif

namespace tom
{
  /**
   * This class represents edges that determine the adjacency of nodes in a cost graph
   *
   * @param[in,out] first  lower node index for this edge
   * @param[in,out] second upper node index for this edge
   */
  typedef std::pair<uint32_t, uint32_t> GraphEdge;
}

#endif
