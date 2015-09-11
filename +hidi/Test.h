#include "+hidi/any.h"
#include "+hidi/exist.h"
#include "+hidi/find.h"
#include "+hidi/fullfile.h"
#include "+hidi/linspace.h"
#include "+hidi/unique.h"

namespace hidi
{
  class Test
  {
  private:
    static void print(const std::vector<double>& x)
    {
      uint32_t n;
      printf("[");
      for(n = 0; (n+1)<x.size(); ++n)
      {
        printf("%f; ", x[n]);
      }
      printf("%f]", x[n]);
      hidi::newline()
      return;
    }
    
    static void print(const std::vector<int16_t>& x)
    {
      uint32_t n;
      printf("[");
      for(n = 0; (n+1)<x.size(); ++n)
      {
        printf("%d; ", x[n]);
      }
      printf("%d]", x[n]);
      hidi::newline();
      return;
    }
    
    static void print(const std::string& x)
    {
      printf("\"%s\"", x.c_str());
      hidi::newline();
      return;
    }
    
    static void print(const bool& x)
    {
      printf("%s", x ? "true" : "false");
      hidi::newline();
      return;
    }
    
    static void check(const bool& x)
    {
      static int pass = 0;
      static int fail = 0;
      if(x)
      {
        ++pass;
        printf("PASS");
      }
      else
      {
        ++fail;
        printf("FAIL");
      }
      printf(" (%d/%d)", pass, pass+fail);
      hidi::newline();
      return;
    }
    
  public:
    static void any(void)
    {
      std::vector<double> x;
      bool flag;
      printf("any");
      hidi::newline();
      x.resize(5, 0.0);
      print(x);
      flag = hidi::any(x);
      check(flag==false);
      x[3] = -2.5;
      print(x);
      flag = hidi::any(x);
      check(flag==true);
      return;
    }

    static void exist(void)
    {
      std::string x;
      bool flag;
      printf("exist");
      hidi::newline();
      x = "+hidi";
      print(x);
      flag = hidi::exist(x, "file");
      check(flag==false);
      flag = hidi::exist(x, "dir");
      check(flag==true);
      x = "+hidi/hidi.h";
      print(x);
      flag = hidi::exist(x, "file");
      check(flag==true);
      flag = hidi::exist(x, "dir");
      check(flag==false);
      return;
    }

    static void find(void)
    {
      std::vector<double> x;
      std::vector<uint32_t> y;
      printf("find");
      hidi::newline();
      x.resize(5, 0.0);
      x[1] = 3.2;
      x[3] = 3.0;
      x[4] = 3.2;
      print(x);
      y = hidi::find(x, 3.2);
      check(y.size()==2);
      check(y[1]==4);
      y = hidi::find(x, 3.0);
      check(y.size()==1);
      check(y[0]==3);
      return;
    }

    static void fullfile(void)
    {
      std::string a;
      std::string b;
      std::string c;
      printf("fullfile");
      hidi::newline();
      a = "/home";
      b = "user";
      c = hidi::fullfile(a, b);
#ifdef _MSC_VER
      check(!c.compare("\\home\\user"));
#else
      check(!c.compare("/home/user"));
#endif
      return;
    }

    static void linspace(void)
    {
      std::vector<double> x;
      printf("linspace");
      hidi::newline();
      x = hidi::linspace(-1.0/3.0, 2.0/3.0, 4);
      print(x);
      check(x.size()==4);
      check(std::abs(x[1])<EPS);
      return;
    }

    static void unique(void)
    {
      std::vector<int16_t> x;
      std::vector<int16_t> y;
      printf("unique");
      hidi::newline();
      x.resize(5);
      x[0] = 4;
      x[1] = -2;
      x[2] = -2;
      x[3] = 4;
      x[4] = -2;
      print(x);
      y = hidi::unique(x);
      print(y);
      check(y.size()==2);
      check(y[0]==-2);
      check(y[1]==4);
      return;
    }

    Test(void)
    {
      any();
      exist();
      find();
      fullfile();
      linspace();
      unique();
    }
  };
}
