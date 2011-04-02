function [a, b] = MatchSurf(keyA, keyB)
  thresh = 0.02;

  LA = [keyA.laplacian]';
  LB = [keyB.laplacian]';
  
  mapA0 = find(~LA);
  mapB0 = find(~LB);
  
  mapA1 = find(LA);
  mapB1 = find(LB);
  
  A0 = [keyA(mapA0).descriptor];
  B0 = [keyB(mapB0).descriptor];

  A1 = [keyA(mapA1).descriptor];
  B1 = [keyB(mapB1).descriptor];
  
  [a0, b0] = MatchSurf_Distance(A0, B0, thresh);
  [a1, b1] = MatchSurf_Distance(A1, B1, thresh);
  
  a = [mapA0(a0); mapA1(a1)];
  b = [mapB0(b0); mapB1(b1)];
end

function [a, b] = MatchSurf_Distance(A, B, thresh)
  nA = size(A, 2);
  nB = size(B, 2);
  D = zeros(nA, nB);
  for a = 1:nA
    d = bsxfun(@minus, B, A(:, a));
    D(a, :) = sum(d.*d);
  end
  [a, b] = find((D<thresh)&bsxfun(@eq, D, min(D, [], 1))&bsxfun(@eq, D, min(D, [], 2)));
end
