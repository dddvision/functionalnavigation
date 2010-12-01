function residual = computeResidual(translation, rayA, rayB)

if  norm(translation) < eps
    residual = acos(dot(rayA,rayB));
else
    % calculate the normal to the epipolar plane
    normals = cross(repmat(translation,1,size(rayA,2)),rayA);
    
    % normalize the normals
    nNormals = normals./repmat(sqrt(sum(normals.^2)),3,1);
    % TODO: set the residual to zero when the absolute value of the
    % denominator is less than eps
    
    % calculate the error
    residual = dot(nNormals,rayB);
    % TODO: Consider taking the acos of the dot product to get angular error in radians.
    %       This change is debatable because it affects the shape of the distribution.
    % NOTE: rayB is guaranteed to have unit magnitude
end
