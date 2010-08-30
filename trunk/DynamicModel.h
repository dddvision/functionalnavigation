#ifndef DYNAMICMODEL_H
#define DYNAMICMODEL_H

#include <map>
#include <string>
#include <vector>

/* define uint32_t if necessary */
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

#include "WorldTime.h"
#include "TimeInterval.h"
#include "Trajectory.h"

namespace tom
{
  /**
   * This class augments a Trajectory with generic parameter inputs
   * 
   * @see tom::Trajectory
   * A component can connect to multiple framework classes
   * Several member functions interact with groups of parameters called blocks
   * There are seperate block descriptions for initial and extension blocks
   * Each block has zero or more logical parameters and zero or more uint32 parameters
   * Each uint32 parameter may be treated as range-bounded double via static casting
   * The range of uint32 is [0,4294967295]
   */
  class DynamicModel : public Trajectory
  {
  private:
    /**
     * Prevents deep copying or assignment
     */
    DynamicModel(const DynamicModel&){}
    DynamicModel& operator=(const DynamicModel&){}

    /* Storage for component descriptions */
    typedef std::string (*DynamicModelDescription)(void);
    static std::map<std::string,DynamicModelDescription>* pDescriptionList(void)
    {
      static std::map<std::string,DynamicModelDescription> descriptionList;
      return &descriptionList;
    }

    /* Storage for component factories */
    typedef DynamicModel* (*DynamicModelFactory)(const WorldTime, const std::string);
    static std::map<std::string,DynamicModelFactory>* pFactoryList(void)
    {
      static std::map<std::string,DynamicModelFactory> factoryList;
      return &factoryList;
    }

  protected:
    /**
     * Prevents deletion via the base class pointer
     */
    ~DynamicModel(void){}
    
    /**
     * Protected method to construct a component
     *
     * @param[in] initialTime finite lower bound of the trajectory time domain
     * @param[in] uri         (@see tom::Measure)
     *
     * NOTES
     * Each subclass constructor must pass identical arguments to this 
     *   constructor using the syntax this=this@DynamicModel(initialTime,uri);
     */
    DynamicModel(const WorldTime initialTime,const std::string uri){}

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
    static void connect(const std::string name, const DynamicModelDescription cD, const DynamicModelFactory cF)
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
     * @param[in]  name component identifier
     * @return          true if the subclass exists and is connected to this base class
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
     * @param[in] name        component identifier
     * @param[in] initialTime finite lower bound of the trajectory time domain
     * @param[in] uri         (@see tom::Measure)
     * @return                object instance
     *
     * NOTES
     * Do not shadow this function
     * Throws an error if the component is not connected
     */
    static DynamicModel* factory(const std::string name, const WorldTime initialTime, const std::string uri)
    {
      DynamicModel* obj=NULL;
      if(isConnected(name))
      {
        obj=(*pFactoryList())[name](initialTime,uri);
      }
      else
      {
        throw("DynamicModel is not connected to the requested component");
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
     * Get number of parameters in each block
     *
     * @return number of parameters in each block
     */
    virtual uint32_t numInitialLogical(void) const = 0;
    virtual uint32_t numInitialUint32(void) const = 0;
    virtual uint32_t numExtensionLogical(void) const = 0;
    virtual uint32_t numExtensionUint32(void) const = 0;
    
    /**
     * Get the number of extension blocks
     *
     * @return number of extension blocks
     */
    virtual uint32_t numExtensionBlocks(void) = 0;
    
    /**
     * Get parameters
     *
     * @param[in] blockIndex     zero-based block index
     * @param[in] parameterIndex zero-based parameter index within each block
     * @return                   parameter value
     *
     * NOTES
     * Throws an exception if any index is outside of the range specified by other member functions
     */
    virtual bool getInitialLogical(uint32_t parameterIndex) = 0;
    virtual uint32_t getInitialUint32(uint32_t parameterIndex) = 0;
    virtual bool getExtensionLogical(uint32_t blockIndex, uint32_t parameterIndex) = 0;
    virtual uint32_t getExtensionUint32(uint32_t blockIndex, uint32_t parameterIndex) = 0;
    
    /**
     * Set parameters
     *
     * @param[in] blockIndex     zero-based block index
     * @param[in] parameterIndex zero-based parameter index within each block
     * @param[in] parameter      value
     *
     * NOTES
     * Throws an exception if any index is outside of the range specified by other member functions
     */
    virtual void setInitialLogical(uint32_t parameterIndex, bool value) = 0;
    virtual void setInitialUint32(uint32_t parameterIndex, uint32_t value) = 0;
    virtual void setExtensionLogical(uint32_t blockIndex, uint32_t parameterIndex, bool value) = 0;
    virtual void setExtensionUint32(uint32_t blockIndex, uint32_t parameterIndex, uint32_t value) = 0;

    /**
     * Compute the cost associated with a block
     *
     * @param[in] blockIndex zero-based block index
     * @return               non-negative cost associated with each block
     *
     * NOTES
     * A block with zero parameters returns zero cost
     * Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf
     * Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9
     */
    virtual double computeInitialBlockCost(void) = 0;
    virtual double computeExtensionBlockCost(uint32_t blockIndex) = 0;

    /**
     * Extend the time domain by appending one extension block
     *
     * NOTES
     * Has no effect if the upper bound of the domain is infinite
     */
    virtual void extend(void) = 0;
  };
}

#endif
