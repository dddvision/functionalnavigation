// Copyright 2011 Scientific Systems Company Inc., New BSD License
#include "+hidi/Test.h"

int main(void)
{
  try
  {
    hidi::Test test;
    return (EXIT_SUCCESS);
  }
  catch(std::exception& e)
  {
    printf("ERROR: ");
    printf("%s", e.what());
    hidi::newline();
  }
  catch(const char* str)
  {
    printf("ERROR: ");
    printf("%s", str);
    hidi::newline();
  }
  catch(...)
  {
    printf("ERROR: Unhandled exception.");
    hidi::newline();
  }
  return (EXIT_FAILURE);
}
