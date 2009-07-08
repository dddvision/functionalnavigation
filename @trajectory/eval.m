% Evaluate a trajectory at multiple instants


function xt=eval(this,t)

switch( this.type )
  case 'tposquat'
    [a,b]=domain(this);
    t(t<a)=a;
    t(t>b)=b;
    pt=interp1(this.data(1,:),this.data(2:4,:)',t,'linear')';
    qt=interp1(this.data(1,:),this.data(5:8,:)',t,'nearest')';
    xt=[pt;qt];    
  case 'analytic'
    xt=eval(this.data.eval);
  case 'empty'
    xt=[];
  otherwise
    error('unhandled exception');
end

return;
