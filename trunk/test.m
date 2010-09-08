function test(name)

  % display info
  fprintf('\n\nThis is the testbed script for components of the Trajectory Optimization ');
  fprintf('\nManager for Multiple Algorithms and Sensors (TOMMAS).');

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
  breakpoints=dbstatus('-completenames');
  save('temp.mat','breakpoints','name');
  clear('classes');
  load('temp.mat');
  dbstop(breakpoints);

  % set the warning state
  warning('on','all');
  warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

  % add component repository to the path
  componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
  if(isempty(findstr(componentPath,path)))
    addpath(componentPath);
    fprintf('\n\npath added: %s',componentPath);
  end

  % initialize the default pseudorandom number generator
  reset(RandStream.getDefaultStream);

  initialTime=tom.WorldTime(0); % default finite lower bound of trajectory time domain
  uri='matlab:MiddleburyData'; % default data resource identifier
  dynamicModelName='XDynamics'; % default dynamic model name
  measureName='XMeasure'; % default measure name

  fprintf('\n\nname =');
  assert(isa(name,'char'));
  fprintf(' ''%s''',name);
  
  fprintf('\n\ntom.DynamicModel.isConnected = ')
  if(tom.DynamicModel.isConnected(name))
    fprintf('yes');
  else
    fprintf('no');
  end
  fprintf('\ntom.Measure.isConnected = ')
  if(tom.Measure.isConnected(name))
    fprintf('yes');
  else
    fprintf('no');
  end
  fprintf('\ntom.Optimizer.isConnected = ')
  if(tom.Optimizer.isConnected(name))
    fprintf('yes');
  else
    fprintf('no');
  end
  fprintf('\ntom.DataContainer.isConnected = ')
  if(tom.DataContainer.isConnected(name))
    fprintf('yes');
  else
    fprintf('no');
  end

  if(tom.DynamicModel.isConnected(name))
    testbed.DynamicModelTest(name,initialTime,uri);
  end
  if(tom.Measure.isConnected(name))
    testbed.MeasureTest(name,uri);
  end
  if(tom.Optimizer.isConnected(name))
    testbed.OptimizerTest(name,dynamicModelName,measureName);
  end
  if(tom.DataContainer.isConnected(name))
    testbed.DataContainerTest(name);
  end

  fprintf('\n\nDone');

end
