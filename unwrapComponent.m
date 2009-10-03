% Turn a package identifier into an object
%
% INPUT
% pkg = package identifier (directory name without '+' prefix), string
% varargin = arguments for the class constructor
%
% OUTPUT
% obj = instantiated object, class determined by pkg
function obj=unwrapComponent(pkg,varargin)
obj=feval([pkg,'.',pkg],varargin{:});
end
