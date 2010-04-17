% This class represents GPS time in seconds since 1980 JAN 06 T00:00:00
classdef Time < double
  methods
    function this=Time(t)
      this=this@double(t);
    end
  end
end
