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
    this=data;
  case {'analytic','tposquat'}
    this=struct('type',type,'data',data);
  case 'empty'
    this=struct('type',type,'data',[]);
  otherwise
    error('unhandled exception');
end

this=class(this,'trajectory');

return;
