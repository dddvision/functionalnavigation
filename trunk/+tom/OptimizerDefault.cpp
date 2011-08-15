#include "Optimizer.h"

namespace tom
{
  class OptimizerDefault : public Optimizer
  {
  public:
    OptimizerDefault(void) : Optimizer()
    {
      return;
    }

    uint32_t numInitialConditions(void) const
    {
      return (0);
    }

    void defineProblem(std::vector<DynamicModel*>& dynamicModel, std::vector<Measure*>& measure, bool randomize)
    {
      return;
    }

    void refreshProblem(void)
    {
      return;
    }
    
    uint32_t numSolutions(void)
    {
      return (0);
    }

    Trajectory* getSolution(const uint32_t k)
    {
      static Trajectory* x = NULL;
      throw("The default optimizer provides no solutions.");
      return (x);
    }

    double getCost(const uint32_t k)
    {
      throw("The default optimizer provides no solutions.");
      return (0.0);
    }

    void step(void)
    {
      return;
    }

 private:
    static std::string componentDescription(void)
    {
      return ("This default optimizer does nothing and provides no solutions.");
    }

    static Optimizer* componentFactory(void)
    {
      return (new OptimizerDefault());
    }

  protected:
    static void initialize(std::string name)
    {
      connect(name, componentDescription, componentFactory);
    }
    friend class OptimizerDefaultInitializer;
  };

  class OptimizerDefaultInitializer
  {
  public:
    OptimizerDefaultInitializer(void)
    {
      OptimizerDefault::initialize("tom");
    }
  } _OptimizerDefaultInitializer;
}
