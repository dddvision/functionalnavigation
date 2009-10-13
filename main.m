close all;
clear classes;
drawnow;
matlab_version=version('-release');
if(str2double(matlab_version(1:4))<2008)
  error('requires Matlab version 2008a or greater');
end

DISPLAY_OUTPUT=true;

this=tommas(tommasConfig);

while(true)

  [this,xEstimate,cost]=step(this);
  
  fprintf('\n');
  fprintf('\ncost:');
  fprintf('\n%f',cost);
  fprintf('\n');
  
  if(DISPLAY_OUTPUT)
    figure;
    px=exp(-(9/2)*(cost.*cost));
    display(xEstimate,'alpha',px','tmax',4);
    axis('on');
    xlabel('North');
    ylabel('East');
    zlabel('Down');
    drawnow;
  end

end
