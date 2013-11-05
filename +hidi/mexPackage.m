% Attempt once to compile a named package
%
% @param[in]  name  package name
% @param[out] mName name of compiled mex file
function mName = mexPackage(name)
  persistent mNameMap
  if(isempty(mNameMap))
    mNameMap = containers.Map;
  end
  if(~isKey(mNameMap, name))
    mNameMap(name) = [name, '.', name(find(['.', name]=='.', 1, 'last'):end), 'Bridge'];
    bridge = mfilename('fullpath');
    arg{1} = ['-I"', fileparts(fileparts(bridge)), '"'];
    arg{2} = [bridge, '.cpp'];
    arg{3} = '-output';
    cpp = which([fullfile(['+', name], name), '.cpp']);
    arg{4} = [cpp(1:(end-4)), 'Bridge'];
    if(exist(arg{4}, 'file'))
      delete([arg{4}, '.', mexext]);
    end
    fprintf('mex');
    fprintf(' %s', arg{:});
    fprintf('\n');
    mex(arg{:});
  end
  mName = mNameMap(name);
end
