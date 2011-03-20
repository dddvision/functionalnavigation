#ifndef GETCURRENTTIME_H
#define GETCURRENTTIME_H

#include <stddef.h>
#include "WorldTime.h"

#ifndef _MSC_VER
#include <sys/time.h>
#else
#include <windows.h>

struct timezone
{
  int tz_minuteswest; // minutes W of Greenwich
  int tz_dsttime;     // type of dst correction
};

/**
 * Windows version of gettimeofday function
 *
 * @param[out] tv Unix Epoch time structure
 * @param[out] tz Unix Epoch time zone structure
 * @return        always returns zero
 *
 * NOTES
 * Time zone support has been deprecated and has no effect
 *
 * REFERENCE
 * Unlicensed gettimeofday code for Windows retrieved September 2010
 * http://www.suacommunity.com/dictionary/gettimeofday-entry.php
 */
int gettimeofday(struct timeval *tv, struct timezone *tz)
{
  // Define the offset since Unix Epoch Jan 1 1970
  static const unsigned __int64 DELTA_EPOCH_IN_MICROSECS = 11644473600000000Ui64;

  // Define a structure to receive the current Windows filetime
  FILETIME ft;
 
  // Initialize the present time to 0 and the timezone to UTC
  unsigned __int64 tmpres = 0;
  static int tzflag = 0;
 
  if(tv!=NULL)
  {
    // Get number of 100 nanosecond intervals since Jan 1 1601 in a structure 
    GetSystemTimeAsFileTime(&ft);
 
    // Copy the high bits to the 64 bit tmpres, shift it left by 32, then in the low 32 bits
    tmpres |= ft.dwHighDateTime;
    tmpres <<= 32;
    tmpres |= ft.dwLowDateTime;

    // Convert to microseconds
    tmpres /= 10;
 
    // Subtract difference
    tmpres -= DELTA_EPOCH_IN_MICROSECS;
 
    // Finally change microseconds to seconds and place in the seconds value
    tv->tv_sec = (long)(tmpres/1000000UL);
    tv->tv_usec = (long)(tmpres%1000000UL);
  }
 
  return 0;
}

#endif // _MSC_VER

namespace antbed
{
  /**
   * Get the current time of day from the operating system
   *
   * @return current system time in tom.WorldTime format
   *
   * NOTES
   * @see tom::WorldTime
   */
  tom::WorldTime getCurrentTime(void)
  {
    timeval tv;
    long int offset = 315964800; // difference between Jan 6 1980 and Jan 1 1979
    double time;
    gettimeofday(&tv, NULL);
    time = static_cast<double> (tv.tv_sec-offset)+static_cast<double> (tv.tv_usec)/1000000.0;
    return (time);
  }
}

#endif // GETCURRENTTIME_H
