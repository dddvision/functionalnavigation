% This class represents a world time system
% The default reference is GPS time in seconds since 1980 JAN 06 T00:00:00
% Choosing another time system may adversely affect interoperability between framework classes
classdef WorldTime < double
  methods
    function this=WorldTime(t)
      this=this@double(t);
    end
  end
end
