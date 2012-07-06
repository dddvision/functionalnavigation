% Get the current time of day from the operating system
%
% @return current system time
function time = getCurrentTime
  time = etime(clock, [1980, 1, 6, 0, 0, 0]);
  calendar = java.util.GregorianCalendar;
  zone = calendar.getTimeZone;
  offset = (zone.getRawOffset+zone.getDSTSavings)/1000;
  time = time-offset;
end
