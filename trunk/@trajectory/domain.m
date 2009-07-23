% Return the endpoints of the closed time domain of a trajectory


function [a,b]=domain(this)

switch( this.type )
  case 'wobble_1.5'
    % HACK: fixed domain makes this a very limited type
    a=0;
    b=60;
  case 'pendulum_1.5'
    % HACK: fixed domain makes this a very limited type
    a=0;
    b=60;
  case 'tposquat'
    a=this.data(1,1);
    b=this.data(1,end);
  case 'analytic'
    a=eval(this.data.domain.a);
    b=eval(this.data.domain.b);
  case 'empty'
    a=[];
    b=[];
  otherwise
    error('unhandled exception');
end

return;
