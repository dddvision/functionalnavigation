function c=evaluate(this,x,w,tmin,tmax)

fprintf('\n');
fprintf('\n### %s evaluate ###',class(this));

K=numel(x);
fprintf('\nnumber of trajectories = %d',K);

fprintf('\ntime domain lower bound = %f',tmin);
fprintf('\ntime domain upper bound = %f',tmax);

% get sensor event indices
[ka,kb]=domain(this);
k=ka:kb;

% identify sensor events within time domain bounds
t=gettime(this,k);
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
ia=getdata(this,ka);
ib=getdata(this,kb);

figure(1);
imshow(ia);
figure(2);
imshow(cat(3,ia,repmat(0.5,size(ia)),ib));
drawnow;

% computing optical flow for two frames
[Vx_OF, Vy_OF] = computeOF(ia,ib);

% process each trajectory independently
c=zeros(1,K);
for k=1:K
  fprintf('\n');
  fprintf('\nprocessing trajectory %d',k);
  fprintf('\nstatic seed = ');
  fprintf('%d',w(:,k));
  c(k)=sensor_evaluate_individual(this,x{k},w(:,k),Vx_OF,Vy_OF,ta,tb);
  fprintf('\ncost = %f',c(k));
end

end
