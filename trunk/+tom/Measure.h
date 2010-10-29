#ifndef MEASURE_H
#define MEASURE_H

#include <map>
#include <string>
#include <vector>

#include "GraphEdge.h"
#include "Trajectory.h"
#include "Sensor.h"

namespace tom
{
  /**
   * This class defines a graph of measures between sensor data and a trajectory
   *
   * NOTES
   * A component can connect to multiple framework classes
   * A measure may depend on data from multiple sensors
   * Each measure is assumed to be independent
   * Measures do not disclose their sources of information
   * Each graph edge is assumed to be independent, and this means that correlated
   *   sensor noise must be modeled and mitigated behind the measure interface
   */
  class Measure : public Sensor
  {
  private:
    /**
     * Prevents deep copying
     */
    Measure(const Measure&) : Sensor(static_cast<WorldTime> (0.0))
    {}

    /**
     * Prevents assignment
     */
    Measure& operator=(const Measure&)
    {}

    /* Storage for component descriptions */
    typedef std::string (*MeasureDescription)(void);
    static std::map<std::string, MeasureDescription>* pDescriptionList(void)
    {
      static std::map<std::string, MeasureDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef Measure* (*MeasureFactory)(const WorldTime, const std::string);
    static std::map<std::string, MeasureFactory>* pFactoryList(void)
    {
      static std::map<std::string, MeasureFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Protected method to construct a component instance
     *
     * @param[in] initialTime less than or equal to the time stamp of the first data node
     * @param[in] uri         uniform resource identifier as described below
     *
     * NOTES
     * The URI may identify a hardware resource or DataContainer
     * URI examples:
     *   'file://dev/camera0'
     *   'matlab:middleburyData'
     * Each subclass constructor must initialize this base class
     * (MATLAB) Initialize by calling this=this@tom.Measure(initialTime,uri);
     */
    Measure(const WorldTime initialTime, const std::string uri) : Sensor(initialTime)
    {}

    /**
     * Establish connection between framework class and component
     *
     * @param[in] name component identifier
     * @param[in] cD   function pointer or handle that returns a user friendly description
     * @param[in] cF   function pointer or handle that can instantiate the subclass
     *
     * NOTES
     * The description may be truncated after a few hundred characters when displayed
     * The description should not contain line feed or return characters
     * (C++) Call this function prior to the invocation of main() using an initializer class
     * (MATLAB) Call this function from initialize()
     */
    static void connect(const std::string name, const MeasureDescription cD, const MeasureFactory cF)
    {
      if(!((cD==NULL)|(cF==NULL)))
      {
        (*pDescriptionList())[name] = cD;
        (*pFactoryList())[name] = cF;
      }
      return;
    }

  public:
    /**
     * Check if a named subclass is connected with this base class
     *
     * @param[in] name component identifier
     * @return         true if the subclass exists and is connected to this base class
     *
     * NOTES
     * Do not shadow this function
     * A package directory identifying the component must in the environment path
     * Omit the '+' prefix when identifying package names
     */
    static bool isConnected(const std::string name)
    {
      return (pFactoryList()->find(name)!=pFactoryList()->end());
    }

    /**
     * Get user friendly description of a component
     *
     * @param[in] name component identifier
     * @return         user friendly description
     *
     * NOTES
     * Do not shadow this function
     * If the component is not connected then the output is an empty string
     */
    static std::string description(const std::string name)
    {
      std::string str = "";
      if(isConnected(name))
      {
        str = (*pDescriptionList())[name]();
      }
      return (str);
    }

    /**
     * Public method to construct a component instance
     *
     * @param[in] name component identifier
     * @param[in] uri  (@see tom::Measure)
     * @return         new object instance that must be deleted by the caller
     *
     * NOTES
     * Do not shadow this function
     * Throws an error if the component is not connected
     */
    static Measure* create(const std::string name, const WorldTime initialTime, const std::string uri)
    {
      Measure* obj = NULL;
      if(isConnected(name))
      {
        obj = (*pFactoryList())[name](initialTime, uri);
      }
      else
      {
        throw("Measure is not connected to the requested component");
      }
      return (obj);
    }

    /**
     * Initializes connections between a component and one or more framework classes
     *
     * @param[in] name component identifier
     *
     * NOTES
     * (C++) Does nothing and does not require implementation
     * (MATLAB) Implement this as a static function that calls connect()
     */
    static void initialize(std::string name)
    {}

    /**
     * Find a limited set of graph edges in the adjacency matrix of the cost graph
     *
     * @param[in]  naMin    minimum lower node index
     * @param[in]  naMax    maximum lower node index
     * @param[in]  nbMin    minimum upper node index
     * @param[in]  nbMax    maximum upper node index
     * @param[out] edgeList list of edges (MATLAB: N-by-1)
     *
     * NOTES
     * The purpose of this function is solely to reduce calls to compute edge cost
     * If adjacency is hard to compute then include the edge
     * Graph edges may be added on successive calls to refresh, but they are never removed
     * The number of output edges is bounded as follows:
     *   numel(edgeList) <= (nbMax-naMmin+1)*(nbMax-naMin+2)/2
     * All information regarding a unique pair of nodes is grouped such that no duplicate edges are returned
     * Edges are sorted in ascending order of node indices, first by lower index, then by upper index
     * A measure can have data nodes without having any edges present
     * If there are no edges within the selected range then the output is an empty vector
     * @see computeEdgeCost()
     */
    virtual void findEdges(const uint32_t naMin, const uint32_t naMax, const uint32_t nbMin, const uint32_t nbMax, 
      std::vector<GraphEdge>& edgeList) = 0;

    /**
     * Evaluate the cost of a single graph edge given a trajectory
     *
     * @param[in] x         trajectory to evaluate
     * @param[in] graphEdge index of an edge in the cost graph
     * @return              non-negative cost associated with the edge
     *
     * NOTES
     * The input trajectory represents the motion of the body frame relative to a world frame. If the sensor frame is 
     *   not coincident with the body frame, then the sensor frame offset may need to be kinematically composed with the
     *   body frame in order to locate the sensor frame and compute the cost
     * Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf
     * Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9
     * Returns 0 if the specified edge is not found in the graph
     * Returns NaN if the graph edge extends outside of the trajectory domain
     * @see findEdges()
     */
    virtual double computeEdgeCost(const Trajectory* x, const GraphEdge graphEdge) = 0;
    
    /**
     * Virtual base class destructor
     */
    virtual ~Measure(void)
    {}
  };
}

#include "MeasureDefault.cpp"

#endif
