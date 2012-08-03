#ifndef HIDIPEDOMETER_H
#define HIDIPEDOMETER_H

#include <string>
#include "Sensor.h"

namespace hidi
{
  class Pedometer : public virtual Sensor
  {
  private:
    /**
     * Prevents deep copying.
     */
    Pedometer(const Pedometer&);

    /**
     * Prevents assignment.
     */
    Pedometer& operator=(const Pedometer&);

  protected:
    /**
     * Protected constructor.
     */
    Pedometer(void)
    {}
    
  public:
    /**
     * Get step label.
     *
     * @param[in] stepID step identifier
     * @return           step label
     */
    std::string getStepLabel(const uint32_t& stepID)
    {
      std::string stepLabel;
      switch(stepID)
      {
        case 1:
          stepLabel = "Still";
          break; 
        case 2:
          stepLabel = "Remain Seated";
          break;
        case 3:
          stepLabel = "Loiter";
          break; 
        case 4:
          stepLabel = "Remain Seated in Squat";
          break;
        case 5:
          stepLabel = "Jog in Place";
          break;
        case 6:
          stepLabel = "Walk Upstairs";
          break;
        case 7:
          stepLabel = "Walk Downstairs";
          break;
        case 8:
          stepLabel = "Backward";
          break;
        case 9:
          stepLabel = "Right";
          break;
        case 10:
          stepLabel = "Left";
          break;
        case 11:
          stepLabel = "Forward";
          break;
        case 12:
          stepLabel = "Brisk Walk";
          break;
        case 13:
          stepLabel = "Jog";
          break;
        case 14:
          stepLabel = "Run Fast";
          break;
        case 15:
          stepLabel = "Walk Uphill";
          break;
        case 16:
          stepLabel = "Walk Downhill";
          break;
        case 17:
          stepLabel = "Walk Forward Dragging Sand";
          break;
        case 18:
          stepLabel = "Walk Backward Dragging Sand";
          break;
        case 19:
          stepLabel = "Turn CCW 20ft";
          break;
        case 20:
          stepLabel = "Turn CCW 15ft";
          break;
        case 21:
          stepLabel = "Turn CCW 10ft";
          break;
        case 22:
          stepLabel = "Turn CCW 5ft";
          break;
        case 23:
          stepLabel = "Turn CW 20ft";
          break;
        case 24:
          stepLabel = "Turn CW 15ft";
          break;
        case 25:
          stepLabel = "Turn CW 10ft";
          break;
        case 26:
          stepLabel = "Turn CW 5ft";
          break;
        case 27:
          stepLabel = "Belly Crawl";
          break;
        default:
          stepLabel = "Undefined";
          break;
      }
      return (stepLabel);
    }
       
    /**
     * Check for the successful completion of a step measurement.
     *
     * @param[in] node data index
     * @return         flag
     *
     * @note
     * Each node refers to a time period that begins the instant after the previous node and ends at the node.
     * The flag will be true only if the motion was successfully characterized.
     * A false flag indicates either the initial time or the end of an unsuccessful measurement period.
     * Throws an error if the index is out of range.
     */
    virtual bool isComplete(const uint32_t& node) = 0;

    /**
     * Get the mean statistic of magnitude of distance traveled during the measurement period.
     *
     * @param[in] node data index
     * @return         mean statistic
     *
     * @note
     * Throws an error if the measurement is not complete.
     * Throws an error if the index is out of range.
     */
    virtual double getMagnitude(const uint32_t& node) = 0;

    /**
     * Get the standard deviation statistic of magnitude of distance traveled during the measurement period.
     *
     * @param[in] node data index
     * @return         deviation statistic
     *
     * @note
     * This deviation accounts for a representative percentage of mislabled steps.
     * Throws an error if the measurement is not complete.
     * Throws an error if the index is out of range.
     */
    virtual double getDeviation(const uint32_t& node) = 0;
    
    /**
     * Get step identifier.
     *
     * @param[in] node data index
     * @return         step identifier
     *
     * @note
     * Throws an error if the index is out of range.
     * Throws an error if the measurement is not complete.
     */
    virtual uint32_t getStepID(const uint32_t& node) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Pedometer(void)
    {}
  };
}

#endif
