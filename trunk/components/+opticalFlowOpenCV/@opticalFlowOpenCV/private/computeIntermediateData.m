function data=computeIntermediateData(this,ka,kb)

  ia=getImage(this.sensor,ka);
  ib=getImage(this.sensor,kb);
  
  switch( interpretLayers(this.sensor) )
    case {'rgb','rgbi'}
      ia=rgb2gray(ia(:,:,1:3));
      ib=rgb2gray(ib(:,:,1:3));
    case {'hsv','hsvi'}
      ia=ia(:,:,3);
      ib=ib(:,:,3);
    otherwise
      % do nothing
  end

  [pixA,pixB]=mexOpticalFlowOpenCV(double(ia),double(ib),double(this.isDense),this.windowSize,this.levels);
  data=struct('pixA',pixA,'pixB',pixB);
  
end
  
% add 1 to indicies for matlab representation
% pixA = pixA+1;
% pixB = pixB+1;
% 
% figure(1); clf;
% if this.isDense
%     u = pixA(:,1) - pixB(:,1);
%     v = pixA(:,2) - pixB(:,2);
%     u = reshape(u,size(I1));
%     v = reshape(v,size(I1));
%     
%     % remove points with big OF
%     THRES = 40;
%     ind = find(u>THRES | u<-THRES);
%     u(ind) = NaN;
%     ind = find(v>THRES | v<-THRES);
%     v(ind) = NaN;
%     SAMPLE_SIZE = 10;
%     SCALE = 5;
%     im(I1(1:SAMPLE_SIZE:end,1:SAMPLE_SIZE:end),[],0);
%     hold('on');
%     quiver( u(1:SAMPLE_SIZE:end,1:SAMPLE_SIZE:end),...
%         v(1:SAMPLE_SIZE:end,1:SAMPLE_SIZE:end), SCALE,'-b'); hold('off');
% 
% else
%     % plot results
%     colormap('gray');
%     imagesc(I1);
%     hold on;
%     for ind = 1: size(pixA,1)
%         line([pixA(ind,1) pixB(ind,1)], [pixA(ind,2) pixB(ind,2)], 'Color', 'c');
%     end
%     hold off;
% end
