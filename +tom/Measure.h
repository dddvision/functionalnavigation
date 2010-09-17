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
    Measure(const Measure&)
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
    typedef Measure* (*MeasureFactory)(const std::string);
    static std::map<std::string, MeasureFactory>* pFactoryList(void)
    {
      static std::map<std::string, MeasureFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Protected method to construct a component instance
     *
     * @param[in] uri (@see tom::Measure)
     *
     * NOTES
     * The URI may identify a hardware resource or DataContainer
     * URI examples:
     *   'file://dev/camera0'
     *   'matlab:middleburyData'
     * Each subclass constructor should initialize this base class
     * (MATLAB) Initialize by calling this=this@tom.Measure(uri);
     */
    Measure(const std::string uri)
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
    static Measure* factory(const std::string name, const std::string uri)
    {
      Measure* obj = NULL;
      if(isConnected(name))
      {
        obj = (*pFactoryList())[name](uri);
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
     * @param[in] x      predicted trajectory that can be used to compute the graph structure
     * @param[in] naSpan maximum difference between lower node index and last node index
     * @param[in] nbSpan maximum difference between upper node index and last node index
     * @return           list of edges (MATLAB: N-by-1)
     *
     * NOTES
     * Graph edges may extend outside of the domain of the input trajectory
     * Graph edges may be added on successive calls to refresh, but they are never removed
     * The number of returned graph edges is bounded as follows:
     *   numel(edgeList) <= (naSpan+1)*(nbSpan+1)
     * All information from this measure regarding a unique pair of nodes must be grouped such that
     *   there are no duplicate graph edges in the output
     * Edges are sorted in ascending order of node indices,
     *   first by lower index, then by upper index
     * If there are no graph edges, then the output is an empty vector
     */
    virtual std::vector<GraphEdge> findEdges(const Trajectory& x, const uint32_t naSpan, const uint32_t nbSpan) = 0;

    /**
     * Evaluate the cost of a single graph edge given a trajectory
     *
     * @param[in] x         trajectory to evaluate
     * @param[in] graphEdge index of a graph edge in the cost graph returned by findEdges()
     * @return              non-negative cost associated with the graph edge
     *
     * NOTES
     * The input trajectory represents the motion of the body frame relative
     *   to a world frame. If the sensor frame is not coincident with the
     *   body frame, then the sensor frame offset may need to be
     *   kinematically composed with the body frame to locate the sensor
     * Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf
     * Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9
     * Throws an exception if the cost cannot be computed for any reason
     * Throws an exception if the computed cost is NaN
     */
    virtual double computeEdgeCost(const Trajectory& x, const GraphEdge graphEdge) = 0;
    
    /**
     * Virtual base class destructor
     */
    virtual ~Measure(void)
    {}
  };
}

#endif
