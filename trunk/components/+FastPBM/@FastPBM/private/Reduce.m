% Reduce image by smoothed subsampling
% Performs horizontal and vertical convolution seperately
% The implied coordinate system originates at
%   the center of the image
% Special thanks to Sohaib Khan

function yout = Reduce(yin)

  [m,n,p]=size(yin);
  if( mod(m,2)||mod(n,2) )
    error('image height and width must be multiples of 2');
  end

  %convolution mask for smoothed subsampling
  mask = [fspecial('gaussian',[1,6],1),0];

  cl=class(yin);
  yin=double(yin);

  yout = zeros(m/2,n/2,p,cl);
  for layer=1:p

    yinp=yin(:,:,layer);

    %horizontal convolution
    yh = conv2(yinp,mask,'same');
    yh = yh(:,1:2:n); %subsampling

    %vertical convolution
    yv = conv2(yh,mask','same');
    yout(:,:,layer) = cast(yv(1:2:m,:),cl); %resampling

  end

end
