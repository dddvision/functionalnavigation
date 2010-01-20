clc;
clear;
mex -I"C:\Program Files\OpenCV\cv\include" ...
    -I"C:\Program Files\OpenCV\cxcore\include"...
    -I"C:\Program Files\OpenCV\otherlibs\highgui" ...
    -L"C:\Program Files\OpenCV\lib\" ...
    MEXOFLKPyr.cpp ...
    runOpticalFlow.cpp -lcv -lcvaux -lhighgui -lcxcore

% test images
I1  = imread('view0.pgm');
I2  = imread('view1.pgm');

% only pass double gray images
isDense =0; % pass 0 to compute OF over good corners only
windowSize= 9;
levels = 5;
[r1,r2] = MEXOFLKPyr(double(I1),double(I2),isDense,windowSize,levels);

% add 1 to indicies for matlab representation
r1 = r1+1;
r2 = r2+1;

figure(1); clf;
if isDense
    u = r1(:,1) - r2(:,1);
    v = r1(:,2) - r2(:,2);
    u = reshape(u,size(I1));
    v = reshape(v,size(I1));
    
    % remove points with big OF
    THRES = 40;
    ind = find(u>THRES | u<-THRES);
    u(ind) = NaN;
    ind = find(v>THRES | v<-THRES);
    v(ind) = NaN;
    SAMPLE_SIZE = 10;
    SCALE = 5;
    im(I1(1:SAMPLE_SIZE:end,1:SAMPLE_SIZE:end),[],0);
    hold('on');
    quiver( u(1:SAMPLE_SIZE:end,1:SAMPLE_SIZE:end),...
        v(1:SAMPLE_SIZE:end,1:SAMPLE_SIZE:end), SCALE,'-b'); hold('off');

else
    % plot results
    colormap('gray');
    imagesc(I1);
    hold on;
    for ind = 1: size(r1,1)
        line([r1(ind,1) r2(ind,1)], [r1(ind,2) r2(ind,2)], 'Color', 'c');
    end
    hold off;
end;

