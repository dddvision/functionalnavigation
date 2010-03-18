% Turn a package identifier into an object
%
% INPUT
% pkg = package identifier (directory name without '+' prefix), string
% varargin = arguments for the class constructor
%
% OUTPUT
% obj = object instance, class determined by pkg
%
% NOTES
% The package directory must be on the path
function obj=unwrapComponent(pkg,varargin)
  try
    obj=feval([pkg,'.',pkg],varargin{:});
  catch err
    error('%s\n%s',err.message,'TOMMAS component could not be instantiated or was not found in the MATLAB path.');
  end
end
