% check MATLAB version
try
  matlabVersion=version('-release');
catch err
  error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB',err.message);
end
if(str2double(matlabVersion(1:4))<2009)
  error('\nTOMMAS requires MATLAB version 2009a or greater');
end

% close figures and clear everything except breakpoints
close('all');
breakpoints=dbstatus;
save('breakpoints','breakpoints');
clear('classes');
load('breakpoints');

% set the warning state
warning('on','all');
warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

% add component repository to the path
componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
addpath(componentPath);
fprintf('\npath added: %s',componentPath);

% initialize the default pseudorandom number generator
reset(RandStream.getDefaultStream);
