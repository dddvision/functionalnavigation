% This class defines a 6-DOF body trajectory in the vicinity of Earth
classdef Trajectory < handle
  
  methods (Abstract=true)
    % Return the upper and lower bounds of the time domain of a trajectory
    %
    % OUTPUT
    % interval = time domain bounds, TimeInterval scalar
    interval=domain(this);
    
    % Evaluate a single trajectory at multiple instants
    %
    % INPUT
    % t = time stamps, WorldTime 1-by-N
    %
    % OUTPUT
    % pose = pose at each time, Pose 1-by-N
    %
    % NOTES
    % Evaluation outside of the domain returns NaN in corresponding outputs
    pose=evaluate(this,t);
    
    % Evaluate the tangent of a single trajectory at multiple time instants
    %
    % INPUT
    % t = time stamps, WorldTime 1-by-N
    %
    % OUTPUT
    % tantentPose = tangent pose at each time, TangentPose 1-by-N
    %
    % NOTES
    % Evaluation outside of the domain returns NaN in corresponding outputs
    tangentPose=tangent(this,t);
  end
  
end
