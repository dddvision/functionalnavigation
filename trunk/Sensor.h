namespace tommas
{
  typedef unsigned int NodeIndex;

  class Sensor
  {
  public:
    void refresh(void);
    bool hasData(void);
    NodeIndex first(void);
    NodeIndex last(void);
    double getTime(NodeIndex);
  };
}

