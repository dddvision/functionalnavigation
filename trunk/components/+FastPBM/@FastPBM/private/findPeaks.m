% Finds pixels that correspond to the local maximum within a sliding window
%
% @param[in] img image to process
% @param[in] win region size to process
% @return        logical image that is true at the peaks and false elsewhere
function peaks=findPeaks(img,win)
  peaks=(img==colfilt(img,[win,win],'sliding','max'));
end
