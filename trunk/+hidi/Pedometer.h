#ifndef HIDIPEDOMETER_H
#define HIDIPEDOMETER_H

#include <map>
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
     * Get number of step labels.
     *
     * @return number of step labels
     */
    static uint32_t numStepLabels(void)
    {
      return (28);
    }
    
    /**
     * Convert step ID to label.
     *
     * @param[in] stepID step identifier
     * @return           step label
     */
    static std::string idToLabel(const uint32_t& stepID)
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
          stepLabel = "Run";
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
          stepLabel = "Crawl";
          break;
        default:
          stepLabel = "Undefined";
          break;
      }
      return (stepLabel);
    }
    
    /**
     * Convert step label to ID.
     *
     * @param[in] stepLabel step label
     * @return              step identifier
     */
    static uint32_t labelToID(const std::string& stepLabel)
    {
      static std::map<std::string, uint32_t> lookup;
      std::map<std::string, uint32_t>::iterator iterator;
      uint32_t stepID;
      if(lookup.size()==0)
      {
        for(stepID = 0; stepID<28; ++stepID)
        {
          lookup[Pedometer::idToLabel(stepID)] = stepID;
        }
      }
      iterator = lookup.find(stepLabel);
      if(iterator==lookup.end())
      {
        stepID = 0;
      }
      else
      {
        stepID = iterator->second;
      }
      return (stepID);
    }
    
    /**
     * Simplify a step identifier to fall within a limited set of classes.
     *
     * @param[in] stepID any step identifier
     * @return           simplified step identifier
     * 
     * @note
     * The return value identifies one of the following labels:
     *   "Still"     zero displacement and zero rotation
     *   "Loiter"    zero displacement
     *   "Backward"  negative sign along forward axis
     *   "Right"     positive sign along right axis
     *   "Left"      negative sign along right axis
     *   "Forward"   positive sign along forward axis
     *   "Run"       positive sign along forward axis
     *   "Crawl"     positive sign along forward axis
     *   "Undefined" undefined
     */
    static uint32_t simplifyStepID(const uint32_t& stepID)
    {
      uint32_t simpleID;
      switch(stepID)
      {
      case 1:
      case 2:
      case 4:
        simpleID = 1; // Still
        break; 
      case 3:
      case 5:
        simpleID = 3; // Loiter
        break; 
      case 8:
      case 18:
        simpleID = 8; // Backward
        break;
      case 9:
        simpleID = 9; // Right
        break;
      case 10:
        simpleID = 10; // Left
        break;
      case 6:
      case 7:
      case 11:
      case 12:
      case 15:
      case 16:
      case 17:
      case 19:
      case 20:
      case 21:
      case 22:
      case 23:
      case 24:
      case 25:
      case 26:
        simpleID = 11; // Forward
        break;
      case 13:
      case 14:
        simpleID = 14; // Run
        break;
      case 27:
        simpleID = 27; // Crawl
        break;
      default:
        simpleID = 0; // Undefined
        break;
      }
      return (simpleID);
    }
    
    /**
     * Check for successful labeling of a step measurement.
     *
     * @param[in] node data index (MATLAB: M-by-N)
     * @return         flag (MATLAB: M-by-N)
     *
     * @note
     * Each node refers to a time period that begins the instant after the previous node and ends at the node.
     * The flag will be true only if the motion was successfully labeled.
     * A false flag indicates either the first node or the end of an unlabeled measurement period.
     * Throws an exception if any index is out of range.
     */
    virtual bool isStepComplete(const uint32_t& n) = 0;

    /**
     * Get the mean statistic of magnitude of distance traveled during the measurement period.
     *
     * @param[in] node data index (MATLAB: M-by-N)
     * @return         mean statistic (meters) (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if the step is not complete.
     * Throws an exception if any index is out of range.
     */
    virtual double getStepMagnitude(const uint32_t& n) = 0;

    /**
     * Get the standard deviation statistic of magnitude of distance traveled during the measurement period.
     *
     * @param[in] node data index (MATLAB: M-by-N)
     * @return         deviation statistic (meters) (MATLAB: M-by-N)
     *
     * @note
     * This deviation accounts for a representative percentage of mislabled steps.
     * Throws an exception if the step is not complete.
     * Throws an exception if any index is out of range.
     */
    virtual double getStepDeviation(const uint32_t& n) = 0;
    
    /**
     * Get the step identifier corresponding to the measurement period.
     *
     * @param[in] node data index (MATLAB: M-by-N)
     * @return         step identifier (MATLAB: M-by-N)
     *
     * @note
     * Throws an exception if the step is not complete.
     * Throws an exception if any index is out of range.
     */
    virtual uint32_t getStepID(const uint32_t& n) = 0;
    
    /**
     * Virtual base class destructor.
     */
    virtual ~Pedometer(void)
    {}
  };
}

#endif
