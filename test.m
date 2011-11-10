function test(name)

  % display info
  fprintf('\n\nThis is the testbed script for components of the Trajectory Optimization Manager ');
  fprintf('\nfor Multiple Algorithms and Sensors (TOMMAS).');

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
  if(isempty(strfind(path, componentPath)))
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

  summary = cell(0, 2);
  for nameIndex = 1:numel(name)
     % close figures and clear everything except breakpoints and necessary arguments
    breakpoints = dbstatus('-completenames');
    save('temp.mat', 'breakpoints', 'name', 'nameIndex', 'summary');
    close('all');
    clear('all');
    clear('classes');
    load('temp.mat');
    dbstop(breakpoints);

    % set the warning state
    warning('on', 'all');
    warning('off', 'MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

    % initialize the default pseudorandom number generator
    RandStream.getGlobalStream.reset();
    
    % get test configuration
    config = TestConfig;

    message = 'ok';
    if(numel(name)==1)
      testComponent(name{nameIndex}, config);
    else
      try
        testComponent(name{nameIndex}, config);
      catch err
        message = err.message;
      end
    end
    summary = cat(1, summary, {name{nameIndex}, message});  
  end
  
  fprintf('\n\n*** Begin Summary ***\n');
  numMessages = size(summary, 1);
  name = char(summary{:, 1});
  for nameIndex = 1:numMessages
    fprintf('\n%s = %s', name(nameIndex, :), summary{nameIndex, 2});
  end
  if(numMessages>0)
    fprintf('\n');
  end
  fprintf('\n*** End Summary ***');

end

function testComponent(name, config)
  isDynamicModel = tom.DynamicModel.isConnected(name);
  isMeasure = tom.Measure.isConnected(name);
  isOptimizer = tom.Optimizer.isConnected(name);
  isDataContainer = antbed.DataContainer.isConnected(name);

  if(isDynamicModel||isMeasure||isOptimizer||isDataContainer)
    fprintf('\n\n*** Begin Component Test ***\n');

    fprintf('\nname =');
    assert(isa(name, 'char'));
    fprintf(' ''%s''', name);

    fprintf('\nDynamicModel.isConnected = %d', isDynamicModel);
    fprintf('\nMeasure.isConnected = %d', isMeasure);
    fprintf('\nOptimizer.isConnected = %d', isOptimizer);
    fprintf('\nDataContainer.isConnected = %d', isDataContainer);

    if(isDynamicModel)
      antbed.DynamicModelTest(name, config.initialTime, config.uri);
    end
    if(isMeasure)
      antbed.MeasureTest(name, config.initialTime, config.uri, config.characterizeMeasures);
    end
    if(isOptimizer)
      antbed.OptimizerTest(name, config.dynamicModelName, config.measureNames, config.initialTime, config.uri);
    end
    if(isDataContainer)
      antbed.DataContainerTest(name, config.initialTime);
    end

    fprintf('\n\n*** End Component Test ***');
  else
    error('disconnected');
  end
end
