% Turn a package identifier into an object
%
% INPUT
% pkg = package identifier, string
% varargin = arguments for the class constructor
%
% OUTPUT
% obj = data container instance
%
% NOTES
% The package directory must in the environment path
% (MATLAB) Omit the '+' prefix when identifying package names
function obj=dataContainerFactory(pkg,varargin)
  obj=feval([pkg,'.',pkg],varargin{:});
  assert(isa(obj,'dataContainer'));
end
