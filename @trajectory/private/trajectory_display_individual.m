function h=trajectory_display_individual(this,alpha,scale,color,tmin,tmax)
h=[];

bigsteps=10;
substeps=10;

t=tmin:((tmax-tmin)/bigsteps/substeps):tmax;

pq=evaluate(this,t);
p=pq(1:3,:);
q=pq(4:7,:);

h=[h,trajectory_display_plotframe(p(:,1),q(:,1),alpha,scale,color)]; % plot first frame
for bs=1:bigsteps
  ksub=(bs-1)*substeps+(1:(substeps+1));
  h=[h,trajectory_display_plotline(p(1,ksub),p(2,ksub),p(3,ksub),alpha,scale,color)]; % plot line segments
  h=[h,trajectory_display_plotframe(p(:,ksub(end)),q(:,ksub(end)),alpha,scale,color)]; % plot terminating frame
end

end
