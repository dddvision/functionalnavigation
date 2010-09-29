function test(name)

  % display info
  fprintf('\n\nThis is the testbed script for components of the Trajectory Optimization ');
  fprintf('\nManager for Multiple Algorithms and Sensors (TOMMAS).');
  
  fprintf('\n\n*** Begin Configuration Test ***\n');
  
  % check MATLAB version
  fprintf('\nmatlabVersion =');
  try
    matlabVersion=version('-release');
  catch err
    error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB',err.message);
  end
  if(str2double(matlabVersion(1:4))<2009)
    error('\nTOMMAS requires MATLAB version 2009a or greater');
  end
  fprintf(' %s',matlabVersion);
  
  % close figures
  fprintf('\nclose =');
  close('all');
  fprintf(' ok');
  
  % clear everything except breakpoints
  fprintf('\nclear =');
  breakpoints=dbstatus('-completenames');
  save('temp.mat','breakpoints','name');
  clear('classes');
  load('temp.mat');
  dbstop(breakpoints);
  fprintf(' ok');

  % add component repository to the path
  componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
  if(isempty(findstr(componentPath,path)))
    addpath(componentPath);
    fprintf('\naddpath = %s',componentPath);
  end
  
  % set the warning state
  warning('on','all');
  warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

  % initialize the default pseudorandom number generator
  RandStream.getDefaultStream.reset();

  % testbed configuration
  uri='matlab:MiddleburyData'; % default data resource identifier
  dynamicModelName='Default'; % default dynamic model name
  measureName='Default'; % default measure name
  
  % get system time
  initialTime=tom.getCurrentTime();
  
  fprintf('\n*** End Configuration Test ***');

  % recurse through all packages if the input argument is 'all'
  if(strcmp(name,'all'))
    allPackages=meta.package.getAllPackages;
    for pkg=1:numel(allPackages)
      try
        testbed.ComponentTest(allPackages{pkg}.Name,dynamicModelName,measureName,initialTime,uri);
      catch err
        fprintf(err.message);
      end
    end
  else
    testbed.ComponentTest(name,dynamicModelName,measureName,initialTime,uri);
  end

end
