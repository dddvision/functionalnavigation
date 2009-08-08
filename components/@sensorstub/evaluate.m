function c=evaluate(this,x,w,tmin,tmax)

fprintf('\n');
fprintf('\n### sensorstub evaluate ###');

K=numel(x);
fprintf('\nnumber of trajectories = %d',K);

fprintf('\ntime domain lower bound = %f',tmin);
fprintf('\ntime domain upper bound = %f',tmax);

c=zeros(1,K);
for k=1:K
  fprintf('\n');
  fprintf('\nprocessing trajectory %d',k);
  fprintf('\nstatic seed = ');
  fprintf('%d',w(:,k));
  c(k)=0.5;
  fprintf('\ncost = %f',c(k));
end

end
