function rgb=file2rgb(fname)
  base=fileparts(mfilename('fullpath'));
  rgb=imread(fullfile(base,fname));
end
