function data = computeIntermediateData(this, nA, nB)

  % get data from the tracker
  numA = this.tracker.numFeatures(nA);
  numB = this.tracker.numFeatures(nB);
  kA = (uint32(1):numA)-uint32(1);
  kB = (uint32(1):numB)-uint32(1);
  idA = this.tracker.getFeatureID(nA, kA);
  idB = this.tracker.getFeatureID(nB, kB);
  
  % find features common to both images
  [idAB, indexA, indexB] = intersect(double(idA), double(idB)); % only supports double
  kA = kA(indexA);
  kB = kB(indexB);

  % get corresponding rays
  rayA = this.tracker.getFeatureRay(nA, kA);
  rayB = this.tracker.getFeatureRay(nB, kB);
  
  % project to image space
  pixA = this.sensor.projection(rayA, nA);
  pixB = this.sensor.projection(rayB, nB);
  
  % store pixel locations
  data = struct('pixA', pixA', 'pixB', pixB');
  
%   if(this.displayFlow)
%     pixA=pixA+1;
%     pixB=pixB+1;
%     figure;
%     colormap('gray');
%     imagesc(ia);
%     hold('on');
%     for ind = 1: size(pixA,1)
%       line([pixA(ind,1) pixB(ind,1)], [pixA(ind,2) pixB(ind,2)],'Color','c');
%     end
%     hold('off');
%   end
%   
end
