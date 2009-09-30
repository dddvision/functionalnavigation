function rgb=getMiddleburyArt(num)
  fname=['view',num2str(num,'%d'),'.png'];
  fcache=fullfile(fileparts(mfilename('fullpath')),fname);
  if(~exist(fcache,'file'))
    url=['http://vision.middlebury.edu/stereo/data/scenes2005/FullSize/Art/Illum2/Exp1/',fname];
    fprintf('\ncaching: %s',url);
    urlwrite(url,fcache);
  end
  rgb=imread(fcache);
end
