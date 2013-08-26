#ifndef TOMGRAPHEDGE_H
#define TOMGRAPHEDGE_H

#include "tom.h"

namespace tom
{
  /**
   * This class represents edges that determine the adjacency of nodes in a cost graph.
   *
   * @param[in,out] first  lower node index for this edge
   * @param[in,out] second upper node index for this edge
   */
  typedef std::pair<uint32_t, uint32_t> GraphEdge;
}

#endif
