function R=GetRotMatrix2_omar(angles)
% just a different convension without - in Ry1(1,3)

Rax1 = angles(1)*pi/180;
Ray1 = angles(2)*pi/180;
Raz1 = angles(3)*pi/180;
Rx1 = [1 0 0;
    0 cos(Rax1) -sin(Rax1);
    0 sin(Rax1) cos(Rax1)];

Ry1 = [cos(Ray1) 0 sin(Ray1);
    0   1   0;
    -sin(Ray1) 0 cos(Ray1)];

Rz1 = [cos(Raz1) -sin(Raz1) 0;
    sin(Raz1) cos(Raz1) 0;
    0 0 1];
R= Rx1*Ry1*Rz1;