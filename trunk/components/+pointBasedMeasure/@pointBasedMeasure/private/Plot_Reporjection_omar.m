function Plot_Reporjection_omar(match,points3D,P,K,R,T,im1,im2)
%nonNormalizedMatches,corrS,corrP,corrK,corrR,corrT,im1,im2

%% plot structure
CameraColors = ['g','r','c','m','y'];
figure(4);
C1 = -inv(R(:,:,1))*T(:,1);
plot3(C1(1),C1(3),C1(2), 'x','LineWidth',15,'Color',CameraColors(1));
hold on;
C2 =C1 + -inv(R(:,:,2))*T(:,2);
plot3(C2(1),C2(3),C2(2), 'x','LineWidth',15,'Color',CameraColors(2));
plot3(points3D(1,:),points3D(3,:),points3D(2,:),'o');
p_max = max(max(points3D));
p_min = min(min(points3D));
axis equal;
%axis([p_min-1 p_max+1 p_min-1 p_max+1 p_min-1 p_max+1]);
xlabel('x');
ylabel('z');
zlabel('y');
set(gca, 'ZDir', 'reverse');
hold off;

%% reproject points on the first image!!
ProjectionError1 = [];
figure(1),hold on;
P1 = P(:,:,1);
for pIndex=1:size(points3D,2)
    m = [points3D(:,pIndex);1];
    mp = P1*m;
    mp = mp./mp(3);
    plot(mp(1),mp(2), 'x','Color','r');
    err = sum((match(pIndex,1:2) - mp(1:2)').^2);
    ProjectionError1(pIndex) = err.^.5;
end;
hold off;

%% reproject points on the second image!!
ProjectionError2 = [];
figure(2),hold on;
P2 = P(:,:,2);
for pIndex=1:size(points3D,2)
    m = [points3D(:,pIndex);1];
    mp = P2*m;
    mp = mp./mp(3);
    plot(mp(1),mp(2), 'x','Color','r');
    err = sum((match(pIndex,1:2) - mp(1:2)').^2);
    ProjectionError2(pIndex) = err.^.5;
end;
hold off;


e1 = sum(ProjectionError1)./(size(im1,1).*size(im1,2));
e2 = sum(ProjectionError2)./(size(im2,1).*size(im2,2));
e = (e1 + e2)./2;
fprintf('Reprojection Error: %d\r',e);