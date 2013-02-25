#ifndef HIDIMAKEDIRECTORY_H
#define HIDIMAKEDIRECTORY_H

#include <algorithm>
#include <string>
#include "hidi.h"

#ifdef _MSC_VER
#include <direct.h>
#include <windows.h>
#else
#include <sys/stat.h>
#include <sys/types.h>
#endif

namespace hidi
{
  /**
   * Create a directory given a path name.
   *
   * @param[in] pathName path of the directory to be created
   * @return             true if the directory exists after the operation and false otherwise
   */
  bool makeDirectory(const std::string& pathName)
  {
#ifdef _MSC_VER
    DWORD attributes;
    std::string platformPathName = pathName;
    std::replace(platformPathName.begin(), platformPathName.end(), '/', '\\');
    attributes = GetFileAttributes(platformPathName.c_str());
    if((attributes!=INVALID_FILE_ATTRIBUTES)&&(attributes&FILE_ATTRIBUTE_DIRECTORY))
    {
	    return (true);
    }
    else
    {
      return (_mkdir(platformPathName.c_str())!=(-1));
    }
#else
    struct stat status;
    std::string platformPathName = pathName;
    std::replace(platformPathName.begin(), platformPathName.end(), '\\', '/');
    stat(platformPathName.c_str(), &status);
    if(S_ISDIR(status.st_mode))
    {
      return (true);
    }
    else
    {
      return (mkdir(platformPathName.c_str(), 0770)!=(-1));
    }
#endif
  }
}
  
#endif
