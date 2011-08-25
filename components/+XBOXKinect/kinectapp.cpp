#include "libfreenect.hpp"
#include <pthread.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <unistd.h>
#include <stddef.h>
#include <sys/time.h>
#include <signal.h>

static bool die = false;
void interrupt(int signum)
{ 
  if( (signum==SIGINT)|(signum==SIGTERM) )
  {
    die = true;
  }
  return;
}

namespace tom
{
  /**
   * This class represents a world time system
   *
   * NOTES
   * The default reference is GPS time at the prime meridian in seconds since 1980 JAN 06 T00:00:00
   * Choosing another time system may adversely affect interoperability between framework classes
   */
  typedef double WorldTime;
}

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

class Mutex
{
public:
  Mutex()
  {
    pthread_mutex_init( &m_mutex, NULL );
  }
  void lock()
  {
    pthread_mutex_lock( &m_mutex );
  }
  void unlock()
  {
    pthread_mutex_unlock( &m_mutex );
  }
private:
  pthread_mutex_t m_mutex;
};

class MyFreenectDevice : public Freenect::FreenectDevice
{
public:
  MyFreenectDevice(freenect_context *_ctx, int _index) : Freenect::FreenectDevice(_ctx, _index), 
    m_buffer_depth(640*480*2), 
    m_buffer_video(640*480*3), 
    depth(640*480*2), 
    video(640*480*3), 
    m_new_rgb_frame(false), 
    m_new_depth_frame(false)
  {}
  
  // Do not call directly even in child
  void DepthCallback(void* _depth, uint32_t timestamp)
  {
    m_depth_mutex.lock();
    uint8_t* depth = static_cast<uint8_t*>(_depth);
    std::copy(depth, depth+640*480*2, m_buffer_depth.begin());
    m_new_depth_frame = true;
    m_depth_mutex.unlock();
  }
  
  // Do not call directly even in child
  void VideoCallback(void* _rgb, uint32_t timestamp)
  {
    m_rgb_mutex.lock();
    uint8_t* rgb = static_cast<uint8_t*>(_rgb);
    std::copy(rgb, rgb+640*480*3, m_buffer_video.begin());
    m_new_rgb_frame = true;
    m_rgb_mutex.unlock();
  };
  
  bool getDepth(std::vector<uint8_t> &buffer)
  {
    m_depth_mutex.lock();
    if(m_new_depth_frame)
    {
      buffer.swap(m_buffer_depth);
      m_new_depth_frame = false;
      m_depth_mutex.unlock();
      return(true);
    }
    else
    {
      m_depth_mutex.unlock();
      return(false);
    }
  }
  
  bool getRGB(std::vector<uint8_t> &buffer)
  {
    m_rgb_mutex.lock();
    if(m_new_rgb_frame)
    {
      buffer.swap(m_buffer_video);
      m_new_rgb_frame = false;
      m_rgb_mutex.unlock();
      return(true);
    }
    else
    {
      m_rgb_mutex.unlock();
      return(false);
    }
  }
  
  void recordRawData(void)
  {
    static unsigned int count = 0;
    static char str[256];

    updateState();

    if(getDepth(depth))
    {
      getRGB(video);

      sprintf(str, "time%06u.dat", count);
      timeFile.open(str, std::ios::out | std::ios::binary);
      sprintf(str, "%016.6lf", antbed::getCurrentTime());
      timeFile << str << std::endl;
      timeFile.close();

      sprintf(str, "depth%06u.dat", count);
      depthFile.open(str, std::ios::out | std::ios::binary);
      depthFile.write(reinterpret_cast<char*>(&depth[0]), 640*480*2);
      depthFile.close();

      sprintf(str, "video%06u.dat", count);
      videoFile.open(str, std::ios::out | std::ios::binary);    
      videoFile.write(reinterpret_cast<char*>(&video[0]), 640*480*3);
      videoFile.close();

      ++count;
    }

    return;
  }

private:
   std::vector<uint8_t> m_buffer_depth;
  std::vector<uint8_t> m_buffer_video;
  std::vector<uint8_t> depth;
  std::vector<uint8_t> video;
  std::ofstream depthFile;
  std::ofstream videoFile;
  std::ofstream timeFile;
  Mutex m_rgb_mutex;
  Mutex m_depth_mutex;
  bool m_new_rgb_frame;
  bool m_new_depth_frame;
};

int main(int argc, char **argv)
{
  Freenect::Freenect freenect;
  MyFreenectDevice* device = &freenect.createDevice<MyFreenectDevice>(0);

  signal(SIGINT,&interrupt);
  
  device->startVideo();
  device->startDepth();
  
  while(!die)
  {
    device->recordRawData();
    usleep(5);
  }
  
  device->stopDepth();
  device->stopVideo();
  
  freenect.deleteDevice(0);
  
  return(0);
}
