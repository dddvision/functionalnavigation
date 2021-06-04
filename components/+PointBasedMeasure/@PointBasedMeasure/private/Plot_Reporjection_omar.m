function Plot_Reporjection_omar(match,points3D,P,K,R,T,im1,im2,ka,kb,DisplayReprojection,DisplayReprojectionOnPictures,PauseBetweenImages)
%nonNormalizedMatches,corrS,corrP,corrK,corrR,corrT,im1,im2
% Copyright 2011 University of Central Florida, New BSD License

%% plot structure
if(DisplayReprojection)
    h=figure(1);
    set(h,'Name','3D Reconstruction','NumberTitle','off');
    plot3(points3D(1,:),points3D(3,:),points3D(2,:),'o');
    hold on;
    C1 = -inv(R(:,:,1))*T(:,1);
    C2 =C1 + -inv(R(:,:,2))*T(:,2);
    
    % initialize x-y-z direction vectors
    xL= xlim;
    yL= zlim;
    VecLen1 = (xL(2) - xL(1))./5;
    VecLen2 = (yL(2) - yL(1))./5;
    VecLen = mean([VecLen1 VecLen2]);
    Shift = VecLen/5;
    
    xVector = [-VecLen 0 0];
    yVector = [0 0 -VecLen];
    zVector = [0 -VecLen 0];
    
    % show first camera
    plot3(C1(1),C1(3),C1(1),'x','LineWidth',10,'Color','k');
    p1 = [C1(1),C1(3),C1(2)];
    p2xVector = R(:,:,1)*xVector';
    p2xVector = p1' + p2xVector;
    line([p1(1) p2xVector(1)],[p1(2) p2xVector(2)],[p1(3) p2xVector(3)],'lineWidth',2.5,'Color','g');
    p2zVector = R(:,:,1)*zVector';
    p2zVector = p1' + p2zVector;
    line([p1(1) p2zVector(1)],[p1(2) p2zVector(2)],[p1(3) p2zVector(3)],'lineWidth',2.5,'Color','y');
    p2yVector = R(:,:,1)*yVector';
    p2yVector = p1' + p2yVector;
    line([p1(1) p2yVector(1)],[p1(2) p2yVector(2)],[p1(3) p2yVector(3)],'lineWidth',2.5,'Color','r');
    text(C1(1)-Shift,C1(3),C1(2)+Shift,'1','LineWidth',10);
    
    % show second camera
    plot3(C2(1),C2(3),C2(2),'x','LineWidth',10,'Color','k');
    p1 = [C2(1),C2(3),C2(2)];
    p2xVector = R(:,:,2)*xVector';
    p2xVector = p1' + p2xVector;
    line([p1(1) p2xVector(1)],[p1(2) p2xVector(2)],[p1(3) p2xVector(3)],'lineWidth',2.5,'Color','g');
    p2zVector = R(:,:,2)*zVector';
    p2zVector = p1' + p2zVector;
    line([p1(1) p2zVector(1)],[p1(2) p2zVector(2)],[p1(3) p2zVector(3)],'lineWidth',2.5,'Color','y');
    p2yVector = R(:,:,2)*yVector';
    p2yVector = p1' + p2yVector;
    line([p1(1) p2yVector(1)],[p1(2) p2yVector(2)],[p1(3) p2yVector(3)],'lineWidth',2.5,'Color','r');
    text(C2(1)+Shift,C2(3),C2(2)+Shift,'2','LineWidth',10);
    axis equal;
    xlabel('Right');
    ylabel('Forward');
    zlabel('Down');
    set(gca, 'ZDir', 'reverse');
    hold off;
    
end

if(DisplayReprojectionOnPictures)
    h=figure(2);
    set(h,'Name','Image Pair','NumberTitle','off');
    clf;
    subplot(1,2,1);
    hold on;
    colormap('gray');
    imshow(im1);
    plot(match(:,1),match(:,2), 'o');
    hold off;
    
    % plot the matches on the second image
    subplot(1,2,2);
    hold on;
    colormap('gray');
    imshow(im2);
    plot(match(:,3),match(:,4), 'o');
    hold off;
    
    % Compute Reprojection coordinates
    P1 = P(:,:,1);
    P2 = P(:,:,2);
    reProj1 = zeros(2,0);
    reProj2 = zeros(2,0);
    for pIndex=1:size(points3D,2)
        m = [points3D(:,pIndex);1];
        mp = P1*m;
        mp = mp./mp(3);
        reProj1(1,pIndex) = mp(1);
        reProj1(2,pIndex) = mp(2);
        mp = P2*m;
        mp = mp./mp(3);
        reProj2(1,pIndex) = mp(1);
        reProj2(2,pIndex) = mp(2);
    end
    
    % Plot reprojection
    subplot(1,2,1),hold on;
    title(['Image ' sprintf('%d',ka)]);
    plot(reProj1(1,:),reProj1(2,:), 'x','Color','r');
    legend('Matched Point','Reprojection','location','SouthOutside');
    hold off;
    
    subplot(1,2,2),hold on;
    title(['Image ' sprintf('%d',kb)]);
    plot(reProj2(1,:),reProj2(2,:), 'x','Color','r');
    legend('Matched Point','Reprojection','location','SouthOutside');
    hold off;  
end

if((DisplayReprojectionOnPictures||DisplayReprojection)&&PauseBetweenImages)
    input('Press [Enter] to continue','s');
end