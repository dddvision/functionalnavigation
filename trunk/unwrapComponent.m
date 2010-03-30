% Turn a package identifier into an object
%
% INPUT
% pkg = package identifier, string
% varargin = arguments for the class constructor
%
% OUTPUT
% obj = object instance, class determined by pkg
%
% NOTES
% The package directory must in the environment path
% (MATLAB) Omit the '+' prefix when identifying package names
function obj=unwrapComponent(pkg,varargin)
  obj=feval([pkg,'.',pkg],varargin{:});
end
