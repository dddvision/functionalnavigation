#ifndef OPTIMIZER_H
#define OPTIMIZER_H

#include <map>
#include <string>
#include <vector>

#include "DynamicModel.h"
#include "Measure.h"

namespace tom
{
  /**
   * This class defines the interface to an optimization engine
   *
   * NOTES
   * A component can connect to multiple framework classes
   */
  class Optimizer
  {
  private:
    /**
     * Prevents deep copying
     */
    Optimizer(const Optimizer&)
    {}

    /**
     * Prevents assignment
     */
    Optimizer& operator=(const Optimizer&)
    {}

    /* Storage for component descriptions */
    typedef std::string (*OptimizerDescription)(void);
    static std::map<std::string, OptimizerDescription>* pDescriptionList(void)
    {
      static std::map<std::string, OptimizerDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef Optimizer* (*OptimizerFactory)(void);
    static std::map<std::string, OptimizerFactory>* pFactoryList(void)
    {
      static std::map<std::string, OptimizerFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Protected method to construct a component instance
     *
     * NOTES
     * Each subclass constructor must initialize this base class
     * (MATLAB) Initialize by calling this=this@tom.Optimizer();
     */
    Optimizer(void)
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
    static void connect(const std::string name, const OptimizerDescription cD, const OptimizerFactory cF)
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
     * @return         new instance that must be deleted by the caller
     *
     * NOTES
     * Do not shadow this function
     * Throws an error if the component is not connected
     */
    static Optimizer* create(const std::string name)
    {
      Optimizer* obj = NULL;
      if(isConnected(name))
      {
        obj = (*pFactoryList())[name]();
      }
      else
      {
        throw("Optimizer is not connected to the requested component");
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
     * Number of initial conditions required to define the problem
     *
     * @return number of initial conditions
     */
    virtual unsigned numInitialConditions(void) const = 0;

    /**
     * Define an optimization problem and set initial conditions
     *
     * @param[in] dynamicModel multiple instances of a single DynamicModel subclass (MATLAB: K-by-1)
     * @param[in] measure      multiple instances of different Measure subclasses (MATLAB: cell M-by-1)
     * @param[in] randomize    setting this to true causes the optimizer to randomize the input trajectories
     *
     * NOTES
     * Does not refresh measures or extend trajectories
     * The the size of the dynamicModel vector must match the number of initial conditions
     * @see refreshProblem()
     * @see numInitialConditions()
     */
    virtual void defineProblem(std::vector<DynamicModel*> &dynamicModel, std::vector<Measure*> &measure,
      bool randomize) = 0;

    /**
     * Refresh all measures and extend trajectory domains equally beyond the last measure
     *
     * NOTES
     * Has no effect in the case that no measures have data
     * Throws an exception if the problem had not been defined
     * @see defineProblem()
     * @see tom::Measure::hasData()
     * @see tom::Measure::refresh()
     * @see tom::DynamicModel::extend()
     */
    virtual void refreshProblem(void) = 0;
    
    /**
     * Get the number of available solutions
     *
     * @return number of solutions
     *
     * NOTES
     * The number of solutions must be less than or equal to the number of initial conditions
     * Returns zero if called before the problem has been defined
     * @see defineProblem()
     */
    virtual unsigned numSolutions(void) = 0;
    
    /**
     * Get a solution in the form of a trajectory
     *
     * @param[in] k zero-based index of solutions
     * @return      trajectory instance associated with the index
     *
     * NOTES
     * Throws an exception if index is greater than or equal to the number of solutions
     * @see numSolutions()
     */
    virtual Trajectory* getSolution(const unsigned k) = 0;

    /**
     * Get a cost estimate associated with a trajectory
     *
     * @param[in] k zero-based index of solutions
     * @return      non-negative cost associated with the index
     *
     * NOTES
     * Throws an exception if index is greater than or equal to the number of solutions
     * @see numSolutions()
     */
    virtual double getCost(const unsigned k) = 0;

    /**
     * Execute one step of the optimizer to evolve dynamic model parameters toward lower cost
     *
     * NOTES
     * Does not refresh measures or extend trajectories
     * Monitors and responds to the growth of all cost graphs from all measures
     * Searches for the minimum cost using as few evaluations as possible
     * May learn about the problem over multiple calls by maintaining state
     * Throws an exception if called before the problem has been defined
     * @see defineProblem()
     * @see refreshProblem()
     */
    virtual void step(void) = 0;
    
    /**
     * Virtual base class destructor
     */
    virtual ~Optimizer(void)
    {}
  };
}

#endif
