function residual = computeResidual(translation, rayA, rayB)
  numRays = size(rayA, 2);
  normal = zeros(3, numRays);
  residual = zeros(1, numRays);
  
  for index = 1:numRays
    % calculate the normal to the epipolar plane
    normal(:, index) = cross(translation, rayA(:, index));

    % normalize vectors
    n = normal(:, index)/norm(normal(:, index));
    % TODO: set the residual to zero when the absolute value of the denominator is less than eps 
    
    % calculate the error
    residual(index) = dot(n, rayB(:, index));
    % TODO: Consider taking the acos of the dot product to get angular error in radians.
    %       This change is debatable because it affects the shape of the distribution.
    % NOTE: rayB is guaranteed to have unit magnitude
  end
end
