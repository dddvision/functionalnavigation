#ifndef TOMDYNAMICMODEL_H
#define TOMDYNAMICMODEL_H

#include <map>
#include <string>
#include <vector>
#include "Trajectory.h"

namespace tom
{
  /**
   * This class augments a Trajectory with generic parameter inputs.
   *
   * @note
   * A component can connect to multiple framework classes.
   * Several member functions interact with groups of parameters called blocks.
   * There are seperate block descriptions for initial and extension blocks.
   * Each block has zero or more uint32 parameters.
   * Each uint32 parameter may be treated as range-bounded double via static casting.
   * The range of uint32 is [0, 4294967295].
   */
  class DynamicModel : public virtual Trajectory
  {
  private:
    /**
     * Prevents deep copying
     */
    DynamicModel(const DynamicModel&);

    /**
     * Prevents assignment
     */
    DynamicModel& operator=(const DynamicModel&);

    /* Storage for component descriptions */
    typedef std::string (*DynamicModelDescription)(void);
    static std::map<std::string, DynamicModelDescription>* pDescriptionList(void)
    {
      static std::map<std::string, DynamicModelDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef DynamicModel* (*DynamicModelFactory)(const double, const std::string);
    static std::map<std::string, DynamicModelFactory>* pFactoryList(void)
    {
      static std::map<std::string, DynamicModelFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Protected method to construct a component instance.
     *
     * @param[in] initialTime finite lower bound of the trajectory time domain
     * @param[in] uri         uniform resource identifier as described below
     *
     * @note
     * Testing is supported by recognizing the URI format 'hidi:dataContainerName'.
     * Hardware implementation is supported by recognizing system resources such as 'file://dev/camera0'.
     * Each subclass constructor must initialize this base class.
     * (MATLAB) Initialize by calling:
     * @code
     *   this=this@tom.DynamicModel(initialTime,uri);
     * @endcode
     */
    DynamicModel(const double initialTime, const std::string uri)
    {}

    /**
     * Establish connection between framework class and component.
     *
     * @param[in] name component identifier
     * @param[in] cD   function pointer or handle that returns a user friendly description
     * @param[in] cF   function pointer or handle that can instantiate the subclass
     *
     * @note
     * The description may be truncated after a few hundred characters when displayed.
     * The description should not contain line feed or return characters.
     * (C++) Call this function prior to the invocation of main() using an initializer class.
     * (MATLAB) Call this function from initialize().
     */
    static void connect(const std::string name, const DynamicModelDescription cD, const DynamicModelFactory cF)
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
     * Alias for a pointer to a dynamic model that is not meant to be deleted.
     */
    typedef DynamicModel* Handle;

    /**
     * Check if a named subclass is connected with this base class.
     *
     * @param[in] name component identifier
     * @return         true if the subclass exists and is connected to this base class
     *
     * @note
     * Do not shadow this function.
     * A package directory identifying the component must in the environment path.
     * Omit the '+' prefix when identifying package names.
     */
    static bool isConnected(const std::string name)
    {
      return (pFactoryList()->find(name)!=pFactoryList()->end());
    }

    /**
     * Get user friendly description of a component.
     *
     * @param[in] name component identifier
     * @return         user friendly description
     *
     * @note
     * Do not shadow this function.
     * If the component is not connected then the output is an empty string.
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
     * Public method to construct a component instance.
     *
     * @param[in] name        component identifier
     * @param[in] initialTime see DynamicModel constructor
     * @param[in] uri         see DynamicModel constructor
     * @return                pointer to a new instance
     *
     * @note
     * Creates a new instance that must be deleted by the caller.
     * Do not shadow this function.
     * Throws an error if the component is not connected.
     */
    static DynamicModel* create(const std::string name, const double initialTime, const std::string uri)
    {
      DynamicModel* obj = NULL;
      if(isConnected(name))
      {
        obj = (*pFactoryList())[name](initialTime, uri);
      }
      else
      {
        throw("DynamicModel is not connected to the requested component");
      }
      return (obj);
    }

    /**
     * Initializes connections between a component and one or more framework classes.
     *
     * @param[in] name component identifier
     *
     * @note
     * Reimplement this as a static function that calls connect().
     */
    static void initialize(std::string name)
    {}

    /**
     * Get number of integer parameters in the initial block.
     *
     * @return number of parameters
     */
    virtual uint32_t numInitial(void) = 0;

    /**
     * Get number of integer parameters in each extension block.
     *
     * @return number of parameters
     */
    virtual uint32_t numExtension(void) = 0;

    /**
     * Get the number of extension blocks.
     *
     * @return number of extension blocks
     *
     * @note
     * The return value increments by one when extend() is called.
     */
    virtual uint32_t numBlocks(void) = 0;

    /**
     * Get an integer parameter from the initial block.
     *
     * @param[in] parameterIndex zero-based parameter index within each block
     * @return                   parameter value
     *
     * @note
     * Throws an exception if any index is outside of the range specified by other member functions.
     */
    virtual uint32_t getInitial(const uint32_t parameterIndex) = 0;

    /**
     * Get an integer parameter from an extension block.
     *
     * @param[in] blockIndex     zero-based block index
     * @param[in] parameterIndex zero-based parameter index within each block
     * @return                   parameter value
     *
     * @note
     * Throws an exception if any index is outside of the range specified by other member functions.
     */
    virtual uint32_t getExtension(const uint32_t blockIndex, const uint32_t parameterIndex) = 0;

    /**
     * Set an integer parameter in the initial block.
     *
     * @param[in] parameterIndex zero-based parameter index within each block
     * @param[in] value          parameter value
     *
     * @note
     * Throws an exception if any index is outside of the range specified by other member functions.
     *
     * @see numBlocks()
     */
    virtual void setInitial(const uint32_t parameterIndex, const uint32_t value) = 0;

    /**
     * Set an integer parameter in an extension block.
     *
     * @param[in] blockIndex     zero-based block index
     * @param[in] parameterIndex zero-based parameter index within each block
     * @param[in] value          parameter value
     *
     * @note
     * Throws an exception if any index is outside of the range specified by other member functions.
     *
     * @see numBlocks()
     */
    virtual void setExtension(const uint32_t blockIndex, const uint32_t parameterIndex, const uint32_t value) = 0;

    /**
     * Compute the cost associated with an initial block.
     *
     * @return non-negative cost associated with each block
     *
     * @note
     * An block with zero parameters returns zero cost.
     * Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf.
     * Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9.
     */
    virtual double computeInitialCost(void) = 0;

    /**
     * Compute the cost associated with an extension block.
     *
     * @param[in] blockIndex zero-based block index
     * @return               non-negative cost associated with each block
     *
     * @note
     * Throws an exception if the block index is outside of the range specified by other member functions.
     * A block with zero parameters returns zero cost.
     * Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf.
     * Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9.
     *
     * @see numBlocks()
     */
    virtual double computeExtensionCost(const uint32_t blockIndex) = 0;

    /**
     * Extend the time domain by incrementing the number of extension blocks by one.
     *
     * @note
     * Has no effect if the upper bound of the domain is infinite.
     */
    virtual void extend(void) = 0;

    /**
     * Explicit deep copy.
     *
     * @return pointer to a new instance that is a copy of this one
     *
     * @note
     * Creates a new instance that must be deleted by the caller.
     */
    virtual DynamicModel* copy(void) = 0;

    /**
     * Virtual base class destructor.
     */
    virtual ~DynamicModel(void)
    {}
  };
}

#endif
