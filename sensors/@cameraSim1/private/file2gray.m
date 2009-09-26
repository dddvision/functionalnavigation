function gray=file2gray(fname)
  base=fileparts(mfilename('fullpath'));
  gray=rgb2gray(imread(fullfile(base,fname)));
end
