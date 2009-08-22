function param=trajectory_display_getparam(str,default,K,varargin)
param=repmat(default,[K,1]);
N=numel(varargin);
for n=1:N
  if( strcmp(varargin{n},str) )
    if( n==N )
      error('optional inputs must be property/value pairs');
    end
    param=varargin{n+1};
    if( ~isa(param,'double') )
      error('values optional inputs be doubles, 1-by-2 or N-by-2');
    end
    if( size(param,1)~=K )
      param=repmat(param(1,:),[K,1]);
    end
  end
end
end
