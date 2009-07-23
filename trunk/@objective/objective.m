% Constructs an object that defines the problem or objective


% TODO: enable a vector of swappable sensors
function H=objective

H.popsize=10;
H.vbits=30;
H.wbits=8;
H.tmin=0;
H.tmax=1.5;
H.F='wobble_1.5'; %'pendulum_1.5'
H.g=sensor;

H=class(H,'objective');

return;
