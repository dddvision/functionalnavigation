// Public Domain
#ifndef HIDIEXIST_H
#define HIDIEXIST_H

#include <fstream>
#include <string>
#include "+hidi/hidi.h"

#ifdef _MSC_VER
#include <direct.h>
#include <windows.h>
#else
#include <sys/stat.h>
#include <sys/types.h>
#endif

namespace hidi
{
  // Check whether a file or directory exists.
  //
  // @param[in] pathName full path to file or directory to check
  // @param[in] kind     kind to check for ("file", "directory", or "" to check either)
  // @return             true if the path name of the specified kind is valid
  bool exist(const std::string& pathName, const std::string& kind)
  {
    std::ifstream file; 
    if(kind.empty())
    {
      return(exist(pathName, "file")||exist(pathName, "dir"));
    }
    else if(!kind.compare("file"))
    {
      if(exist(pathName, "dir"))
      {
        return(false);
      }
      file.open(pathName.c_str(), std::ios::in);
      if(file.is_open())
      {
        file.close();
        return(true);
      }
      else
      {
        return(false);
      }
    }
    else if(!kind.compare("dir"))
    {
#ifdef _MSC_VER
      DWORD attributes;
      attributes = GetFileAttributesA(pathName.c_str());
      return((attributes!=INVALID_FILE_ATTRIBUTES)&&(attributes&FILE_ATTRIBUTE_DIRECTORY));
#else
      struct stat status;
      status.st_mode = 0;
      stat(pathName.c_str(), &status);
      return(S_ISDIR(status.st_mode));
#endif
    }
    return(false);
  }
}

#endif
