% Construct an individual typed trajectory object
%
% INPUTS
% type = string that identifies a user-defined trajectory type
% data = formatted data that represents the user-defined type


function this=trajectory(type,data)

if( nargin==0 )
  this=class(struct('type',{},'data',{}),'trajectory');
  return;
end

switch( type )
  case 'trajectory'
    this=class(data,'trajectory');
  case {'analytic','tposquat'}
    this=class(struct('type',type,'data',data),'trajectory');
  case {'wobble_1.5','pendulum_1.5'}
    K=size(data,2);
    for k=1:K
      datak=data(:,k);
      this(k)=class(struct('type',type,'data',datak),'trajectory');
    end
  case 'empty'
    this=class(struct('type',type,'data',[]),'trajectory');
  otherwise
    error('unhandled exception');
end

end
