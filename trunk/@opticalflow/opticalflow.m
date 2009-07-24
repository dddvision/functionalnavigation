% Constructs an opticalflow object

function o=opticalflow(img1, img2)

% frame 1 and frame 2 on which optical flow needs to be computed
o.img1 = img1; 
o.img2 = img2; 

o=class(o,'opticalflow');

return;