% Evaluate cost associated with trajectory and sensor noise sets
%
% INPUTS
% x = trajectory objects, 1-by-K
% w = sensor noise objects, 1-by-K
% tmin = time domain lower bound
% tmax = time domain upper bound
%
% OUTPUT
% c = cost, 1-by-K
%
% NOTE
% The input trajectory objects represent the motion of the body frame
% relative to a world frame.  If the sensor frame is not coincident with
% the body frame, then transformations may be necessary.
    

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
