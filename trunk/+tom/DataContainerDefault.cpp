namespace tom
{
  class DataContainerDefault : public DataContainer
  {
  public:
    DataContainerDefault(const WorldTime initialTime) : DataContainer(initialTime)
    {
      return;
    }

    void listSensors(const std::string type, std::vector<SensorIndex>& list)
    {
      list.resize(0);
      return;
    }

    std::string getSensorDescription(SensorIndex id)
    {
       static std::string text("");
       throw("This default data container has no data.");
       return (text);
    }

    Sensor& getSensor(SensorIndex id)
    {
      Sensor* sensor = NULL;
      throw("This default data container has no data.");
      return (*sensor); // would crash if we ever got here
    }

    bool hasReferenceTrajectory(void)
    {
      return (false);
    }

    Trajectory* getReferenceTrajectory(void)
    {
      Trajectory* trajectory = NULL;
      throw("This default data container has no data.");
      return (trajectory);
    }

  private:
    static std::string componentDescription(void)
    {
      return ("This default data container has no data.");
    }

    static DataContainer* componentFactory(const WorldTime initialTime)
    {
      return (new DataContainerDefault(initialTime));
    }

  protected:
    static void initialize(std::string name)
    {
      connect(name, componentDescription, componentFactory);
    }
    friend class DataContainerDefaultInitializer;
  };

  class DataContainerDefaultInitializer
  {
  public:
    DataContainerDefaultInitializer(void)
    {
      DataContainerDefault::initialize("tom");
    }
  } _DataContainerDefaultInitializer;
}
