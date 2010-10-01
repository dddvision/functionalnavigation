% Get the current time of day from the operating system
%
% @return current system time in WorldTime format
%
% NOTES
% @see tom:WorldTime
function t = getCurrentTime
  t = tom.WorldTime(etime(clock, [1980, 1, 6, 0, 0, 0]));
end
