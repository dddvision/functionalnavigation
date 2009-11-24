close all;
clear classes;
drawnow;

% check matlab version
matlab_version=version('-release');
if(str2double(matlab_version(1:4))<2008)
  error('requires Matlab version 2008a or greater');
end

% add path to component repository
componentPath=fullfile(fileparts(mfilename),'components');
addpath(genpath(componentPath));
fprintf('\npath added: %s',componentPath);

% run diagnostic tests on a component
%tommas.testComponent('thesisDataDDiel');

% create an instance of the trajectory optimization manager
tom=tommas;

% get initial trajectories and costs
[xEst,cEst]=getResults(tom);
fprintf('\n');
fprintf('\ncost:');
fprintf('\n%f',cEst);

% take an optimization step
tom=step(tom);

% get updated trajectories and costs
[xEst,cEst]=getResults(tom);
fprintf('\n');
fprintf('\ncost:');
fprintf('\n%f',cEst);

% display a graphical summary
figure;
px=exp(-(9/2)*(cEst.*cEst));
display(xEst,'alpha',px','tmax',4);
axis('on');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Altitude');
drawnow;

% done
fprintf('\n');
fprintf('\nDone');
fprintf('\n');
