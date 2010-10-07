function test(name)

  % display info
  fprintf('\n\nThis is the testbed script for components of the Trajectory Optimization ');
  fprintf('\nManager for Multiple Algorithms and Sensors (TOMMAS).');

  % check MATLAB version
  fprintf('\n\nmatlabVersion  =');
  try
    matlabVersion = version('-release');
  catch err
    error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB', err.message);
  end
  if(str2double(matlabVersion(1:4))<2009)
    error('\nTOMMAS requires MATLAB version 2009a or greater');
  end
  fprintf(' %s', matlabVersion);
  
  % add component repository to the path
  componentPath = fullfile(fileparts(mfilename('fullpath')), 'components');
  if(isempty(findstr(componentPath, path)))
    fprintf('\naddpath =');
    addpath(componentPath);
    fprintf(' %s', componentPath);
  end
  
  % process all packages on the path if the input argument is 'all'
  if(strcmp(name, 'all'))
    allPackages = meta.package.getAllPackages;
    numPackages = numel(allPackages);
    name = cell(numPackages,1);
    for packageIndex = 1:numPackages
      name{packageIndex} = allPackages{packageIndex}.Name;
    end
  else
    name = {name};
  end

  errorSummary = cell(0, 2);
  for nameIndex = 1:numel(name)
     % close figures and clear everything except breakpoints and necessary arguments
    breakpoints = dbstatus('-completenames');
    save('temp.mat', 'breakpoints', 'name', 'nameIndex', 'errorSummary');
    close('all');
    clear('classes');
    load('temp.mat');
    dbstop(breakpoints);

    % set the warning state
    warning('on', 'all');
    warning('off', 'MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

    % initialize the default pseudorandom number generator
    RandStream.getDefaultStream.reset();
    
    % get test configuration
    config = TestConfig;

    if(numel(name)==1)
      testbed.ComponentTest(name{nameIndex}, config.dynamicModel, config.measure, config.initialTime, config.uri);
    else
      try
        testbed.ComponentTest(name{nameIndex}, config.dynamicModel, config.measure, config.initialTime, config.uri);
      catch err
        errorSummary = cat(1, errorSummary, {name{nameIndex}, err.message});
      end
    end
  end
  
  fprintf('\n\n*** Begin Summary ***\n');
  numErrors = size(errorSummary, 1);
  name = char(errorSummary{:, 1});
  for nameIndex = 1:numErrors
    fprintf('\n%s = %s', name(nameIndex,:), errorSummary{nameIndex, 2});
  end
  if(numErrors>0)
    fprintf('\n');
  end
  fprintf('\n*** End Summary ***');

end
