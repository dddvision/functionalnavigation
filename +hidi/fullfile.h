// Public Domain
#ifndef HIDIFULLFILE_H
#define HIDIFULLFILE_H

#include <cstdarg>
#include <algorithm>
#include <string>
#include "+hidi/hidi.h"

namespace hidi
{
  // Combines two file path strings.
  //
  // @param[in] a first string
  // @param[in] b second string
  // @param[in] c combined reformatted string
  //
  // @note
  // Inserts a slash between first and second argument if a slash is not present.
  // Always replaces all slashes with those used by the platform file system.
  // Removes repeated slashes from the combined string, except those at the beginning of the string.
  std::string fullfile(const std::string& a, const std::string& b)
  {
#ifdef _MSC_VER
    static const char goodSlash = '\\';
    static const char badSlash = '/';
#else
    static const char goodSlash = '/';
    static const char badSlash = '\\';
#endif
    uint32_t m;
    uint32_t n;
    uint32_t M;
    std::string c;
    if(b.empty())
    {
      c = a;
    }
    else if(a.empty())
    {
      c = b;
    }
    else
    {
      c = a+goodSlash+b;
    }
    // replace bad slashes with good slashes
    std::replace(c.begin(), c.end(), badSlash, goodSlash);
    // if there are at least two characters
    M = c.length();
    if(M>1)
    {
      // skip initial slashes
      m = 1;
      if(c[0]==goodSlash)
      {
        for(; m<M; ++m)
        {
          if(c[m]!=goodSlash)
          {
            break;
          }
        }
      }
      // remove duplicate slashes
      n = m-1;
      for(; m<M; ++m)
      {
        if((c[n]!=goodSlash)|(c[m]!=goodSlash))
        {
          ++n;
          c[n] = c[m];
        }
      }
      c.resize(n+1);
    }
    return (c);
  }
}

#endif
