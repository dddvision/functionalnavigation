% This class represents GPS time in seconds since 1980 JAN 06 T00:00:00
classdef GPSTime < double
  methods
    function this=GPSTime(t)
      this=this@double(t);
    end
  end
end
