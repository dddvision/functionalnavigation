function c=evaluate(g,x,w,tmin,tmax)

% get sensor event indices
[ka,kb]=domain(g);
k=ka:kb;

% identify sensor events within time domain bounds
t=gettime(g,k);
inside=find((t>=tmin)&(t<=tmax));
k=k(inside);
t=t(inside);

% check whether at least two events occurred
if( numel(inside)<2 )
  return;
end

% arbitrarily select the first and last events
ka=k(1);
kb=k(end);
ta=t(1);
tb=t(end);

% get data from sensor
ia=getdata(g,ka);
ib=getdata(g,kb);

figure(1);
imshow(ia);
figure(2);
imshow(cat(3,ia,repmat(0.5,size(ia)),ib));
drawnow;

% computing optical flow for two frames
[Vx_OF, Vy_OF] = computeOF(ia,ib);

% process each trajectory independently
K=numel(x);
c=zeros(1,K);
for k=1:K
  c(k)=sensor_evaluate_individual(g,x(k),w(:,k),Vx_OF,Vy_OF,ta,tb);
end

end
