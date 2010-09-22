% Finds pixels that correspond to the local maximum within a sliding window
%
% win(1) is the height of the window
% win(2) is the width of the window
function peaks=FindPeaks(img,win)
  peaks=(img==colfilt(img,win,'sliding','max'));
end
