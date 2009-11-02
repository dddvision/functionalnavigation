function [Vx,Vy] = computeOF_Pyramids(I1,I2)
%HIERARCHICALLK 	Hierarchical Lucas Kanade (using pyramids)
%                   [u,v]=HierarchicalLK(im1, im2, numLevels, windowSize, iterations, display)
%                   Tested for pyramids of height 1, 2, 3 only... operation with
%                   pyramids of height 4 might be unreliable
%
%                  Use quiver(u, -v, 0) to view the results
%

%% Load and prepare images 
SIZE = [300,300];
im1 = rgb2gray(I1);
im1 = double(imresize(im1,SIZE));
im2 = rgb2gray(I2);
im2 = double(imresize(im2,SIZE));

%% Set parameters
%                  NUMLEVELS    Pyramid Levels (typical value 3)
%                  WINDOWSIZE   Size of smoothing window (typical value 1-4)
%                  ITERATIONS   number of iterations (typical value 1-5)
%                  DISPLAY      1 to display flow fields (1 or 0)

numLevels = 3;
windowSize =4; 
iterations = 3;
display = 0;

% check image sizes and crop if not divisible
if (rem(size(im1,1), 2^(numLevels - 1)) ~= 0)
    warning('image will be cropped in height, size of output will be smaller than input!');
    im1 = im1(1:(size(im1,1) - rem(size(im1,1), 2^(numLevels - 1))), :);
    im2 = im2(1:(size(im1,1) - rem(size(im1,1), 2^(numLevels - 1))), :);
end;

if (rem(size(im1,2), 2^(numLevels - 1)) ~= 0)
    warning('image will be cropped in width, size of output will be smaller than input!');
    im1 = im1(:, 1:(size(im1,2) - rem(size(im1,2), 2^(numLevels - 1))));
    im2 = im2(:, 1:(size(im1,2) - rem(size(im1,2), 2^(numLevels - 1))));
end;

%Build Pyramids
pyramid1 = im1;
pyramid2 = im2;

for i=2:numLevels
    im1 = reduce(im1);
    im2 = reduce(im2);
    pyramid1(1:size(im1,1), 1:size(im1,2), i) = im1;
    pyramid2(1:size(im2,1), 1:size(im2,2), i) = im2;
end;

% base level computation
disp('Computing Level 1');
baseIm1 = pyramid1(1:(size(pyramid1,1)/(2^(numLevels-1))), 1:(size(pyramid1,2)/(2^(numLevels-1))), numLevels);
baseIm2 = pyramid2(1:(size(pyramid2,1)/(2^(numLevels-1))), 1:(size(pyramid2,2)/(2^(numLevels-1))), numLevels);
[u,v] = LucasKanade(baseIm1, baseIm2, windowSize);

for r = 1:iterations
    [u, v] = LucasKanadeRefined(u, v, baseIm1, baseIm2);
end

%propagating flow 2 higher levels
for i = 2:numLevels
    disp(['Computing Level ', num2str(i)]);
    uEx = 2 * imresize(u,size(u)*2);   % use appropriate expand function (gaussian, bilinear, cubic, etc).
    vEx = 2 * imresize(v,size(v)*2);
    
    curIm1 = pyramid1(1:(size(pyramid1,1)/(2^(numLevels - i))), 1:(size(pyramid1,2)/(2^(numLevels - i))), (numLevels - i)+1);
    curIm2 = pyramid2(1:(size(pyramid2,1)/(2^(numLevels - i))), 1:(size(pyramid2,2)/(2^(numLevels - i))), (numLevels - i)+1);
    
    [u, v] = LucasKanadeRefined(uEx, vEx, curIm1, curIm2);
    
    for r = 1:iterations
        [u, v, cert] = LucasKanadeRefined(u, v, curIm1, curIm2);
    end
end;

if (display==1)
  figure, quiver(reduce((reduce(medfilt2(flipud(u),[5 5])))), -reduce((reduce(medfilt2(flipud(v),[5 5])))), 0), axis equal;
end
Vx = u;
Vy = v;
% save Vx.mat Vx;
% save Vy.mat Vy;