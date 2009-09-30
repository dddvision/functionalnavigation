close all;
clear classes;
drawnow;

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
    px=exp(-9*(cost.*cost));
    display(xEstimate,'alpha',px');
    axis('on');
    xlabel('North');
    ylabel('East');
    zlabel('Down');
    drawnow;
  end

end
