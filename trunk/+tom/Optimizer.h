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
     * Prevents deep copying or assignment
     */
    Optimizer(const Optimizer&){}
    Optimizer& operator=(const Optimizer&){}

    /* Storage for component descriptions */
    typedef std::string (*OptimizerDescription)(void);
    static std::map<std::string,OptimizerDescription>* pDescriptionList(void)
    {
      static std::map<std::string,OptimizerDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef Optimizer* (*OptimizerFactory)(const std::vector<DynamicModel*>&, const std::vector<Measure*>&);
    static std::map<std::string,OptimizerFactory>* pFactoryList(void)
    {
      static std::map<std::string,OptimizerFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Prevents deletion via the base class pointer
     */
    ~Optimizer(void){}
    
    /**
     * Protected method to construct a component
     *
     * INPUT
     * @param[in] dynamicModel multiple instances of a single DynamicModel subclass (MATLAB: K-by-1)
     * @param[in] measure      multiple instances of different Measure subclasses (MATLAB: cell M-by-1)
     *
     * NOTES
     * No assumptions should be made about the initial state of the input objects
     * Each subclass constructor should initialize this base class
     * (MATLAB) Initialize by calling this=this@tom.Optimizer(dynamicModel,measure);
     */
    Optimizer(const std::vector<DynamicModel*>& dynamicModel, const std::vector<Measure*>& measure){}
    
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
        (*pDescriptionList())[name]=cD;
        (*pFactoryList())[name]=cF;
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
      return(pFactoryList()->find(name) != pFactoryList()->end());
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
      std::string str="";
      if(isConnected(name))
      {
        str=(*pDescriptionList())[name]();
      }
      return(str);
    }

    /**
     * Public method to construct a component
     *
     * @param[in] name component identifier
     * @param[in] dynamicModel   (@see tom::Optimizer)
     * @param[in] measure        (@see tom::Measure)
     * @return                   object instance
     *
     * NOTES
     * Do not shadow this function
     * Throws an error if the component is not connected
     */
    static Optimizer* factory(const std::string name,
      std::vector<DynamicModel*> &dynamicModel, std::vector<Measure*> &measure)
    {
      Optimizer* obj=NULL;
      if(isConnected(name))
      {
        obj=(*pFactoryList())[name](dynamicModel,measure);
      }
      else
      {
        throw("Optimizer is not connected to the requested component");
      }
      return(obj);
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
    static void initialize(std::string name){};
    
    /**
     * Get the number of results
     *
     * @return number of results
     */
    virtual unsigned numResults(void) = 0;
    
    /**
     * Get the most recent trajectory estimate in the form of a dynamic model
     *
     * @param[in]  k    zero based result index
     * @return          dynamic model instance that is also a trajectory
     *
     * NOTES
     * This function returns initial conditions if called before the first optimization step occurrs
     * Throws an exception if index is out of range
     */
    virtual DynamicModel* getTrajectory(const unsigned k) = 0;
    
    /**
     * Get the most recent cost estimate
     *
     * @param[in] k zero based result index
     * @return      non-negative cost associated with each trajectory instance
     *
     * NOTES
     * This function returns initial conditions if called before the first optimization step occurrs
     * Throws an exception if index is out of range
     */
    virtual double getCost(const unsigned k) = 0;
    
    /**
     * Execute one step of the optimizer to evolve parameters toward lower cost
     *
     * NOTES
     * This function refreshes the objective and determines the current 
     *   number of input parameter blocks and output costs
     * The optimizer may learn about the objective function over multiple
     *   calls by maintaining state using class properties
     * This function may evaluate the objective multiple times, though a
     *   single evaluation per step is preferred
     */
    virtual void step(void) = 0;
  };
}

#endif
