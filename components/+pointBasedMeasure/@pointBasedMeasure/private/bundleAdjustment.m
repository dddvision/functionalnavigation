function [ S P K R t l ] = bundleAdjustment( isProj, sfmCase, W, S0, varargin )
% Bundle Adjustment (using the excellent SBA)
%
% Can perform BA on full camera matrices (3 x 4) or K, R, t
%
% The calibration parameters are given in 3 or 5 by nFrame matrices.
%Each line corresponds to a element:
% Affine
%   K1  K2  0
%   0   K3  0
%   0   0   1
% Projective
%   K1  K2  K4
%   0   K3  K5
%   0   0   1
%
% USAGE
%  [ S P K R t ] = bundleAdjustment( isProj, sfmCase, W, S0, 'R0', R0,...
%                   't0',  t0, varargin )
%  [ S P K R t l ] = bundleAdjustment( false, Inf, W, S0, 'R0', R0, 't0'...
%                t0, 'l', l )
%
% INPUTS
%  isProj    - flag indicating if the camera is projective
%  sfmCase   - 1,2,3, Inf motion+struct, motion only, struct only,
%              NRSFM with shape basis
%  W         - [ 2 x nPoint x nFrame ] 2D projected features
%  S0        - [ 3 x nPoint ] initial 3D features or initial basis in 
%              NRSFM. In NRSFM, S0 is:
%              Torresani's: [ 3 x nPoint x nBasis ]
%              Xiao's: [ 3 x nPoint x nBasis ]
%              where nBasis is the number of bases used is the
%              dimensionality of the shape space
%  varargin   - list of paramaters in quotes alternating with their values
%       - P0   [ 3 x 4 x nFrame ] set of initial camera matrices
%       - R0   [ 3 x 3 x nFrame ] set of initial rotations
%              Quaternions are extracted fromthem so they'd better be real
%              rotation matrices !
%       - t0   [ 3 x nFrame ] set of initial translations
%       - 'WMask', [ nPoint x nFrame ] contains 1 or 0
%               (1 if the feature is present
%       - 'K0', [ 3 x nFrame ] (affine) or [ 5 x nFrame ]
%               (projective) initial calibration matrices
%       - 'KMask', [ 3 x 1 ] or [ 5 x 1 ] contains 1 when the calibration
%               parameter is fixed
%       - 'nItrSBA' number of BA iterations
%       - 'nFrameFixed' [1], number of frames (starting from the first)
%                       whose camera parameters are fixed
%       - 'l', [ dimSSpace  x nFrame ] linear coefficients (for NRSFM) 
%              where dimSSpace is the dimensionality of the shape space.
%
% OUTPUTS
%  S         - [ 3 x nPoint ] 3D structure or [ 3 x nPoint x (dimSSpace+1)]
%              for NRSFM (shape basis) (or [ 3 x nPoint x dimSSpace ] )
%  P         - [ 3 x 4 x nFrame ] projection matrices
%  K         - [ 3 x 3 x nFrame ] calibration matrices
%  R         - [ 3 x 3 x nFrame ] rotation matrices
%  t         - [ 3  x nFrame ] translation vectors
%  t         - [ 3  x nFrame ] translation vectors
%  l         - [ 3 dimSSpace  x nFrame ] linear coefficients (for NRSFM)
%
% EXAMPLE
%
% See also
%
% Vincent's Structure From Motion Toolbox      Version 2.11
% Copyright (C) 2009 Vincent Rabaud.  [vrabaud-at-cs.ucsd.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Lesser GPL [see external/lgpl.txt]

[ P0 R0 t0 WMask K0 KMask nItrSBA l covx nFrameFixed ] = ...
  getPrmDflt( varargin,{ 'P0', [], 'R0', [], 't0', [], 'WMask', [] ...
  , 'K0', [], 'KMask', [], 'nItrSBA', 500, 'l', [], ...
  'covx', [], 'nFrameFixed', 1 } );

nPoint = size( S0, 2 ); nFrame = max( [ size( R0, 3 ) size(P0,3) ] );
if isempty(WMask); WMask = ones(nPoint,nFrame); end

% Figure out where the files are located
switch computer
  case 'PCWIN',
    projPath=[ '@' fileparts(mfilename('fullpath')) ...
      '/private/sba/sbaProjection.dll' ];
  case 'GLNX86'
    projPath=[ '@' fileparts(mfilename('fullpath')) ...
      '/private/sba/sbaProjection.so' ];
end

% Initialize the camera parameters
nBasis = size(S0,3);
if isempty(P0)
  if isempty(KMask)
    if isProj; KMask = ones(5,1); else KMask = ones(3,1); end
  end
  if isempty(K0)
    if isProj K0 = zeros( 5, nFrame ); K0(1,:) = 1; K0(3,:) = 1;
    else K0 = ones( 3, nFrame ); K0(2,:) = 0;
    end
    doK=0;
  else doK=1;
  end
  nK = sum(~KMask);

  % Deal with NRSFM
  switch size(l,1)
    case nBasis, %Xiao
      isFirstCoeff1=false;
    case nBasis-1, %Torresani
      isFirstCoeff1=true;
    otherwise
      if ~isempty(l); error('Problem with the dimension of l and SBasis');end
  end

  % Make sure the rotation matrices are orthonormal
  Q = quaternion(R0);

  %  sba(n, m, mcon, vmask, p0, cnp, pnp, x, covx, mnp, proj, projac, ...
  %itmax, verbose, opts, reftype, varargin)
  pnp=3;
  if isProj % Projective camera
    P0 = [ Q; t0; K0( ~KMask, : ) ]; cnp=7+nK;
  else % Affine camera
    P0 = [ Q; t0(1:2,:); K0( ~KMask, : ) ]; cnp=6+nK;
  end

  if sfmCase==Inf % NRSFM
    P0 = [ P0; l ];
    P0 = [ P0(:)' reshape( permute( S0, [ 1 3 2 ] ), [], 1 )' ];
    if isProj
      error('has to be an affine camera for NRSFM');
    end
    cnp=6+size(l,1);
    pnp=3*nBasis;
    proj='affineNRSFM';
  else
    P0 = [ P0(:)' S0(:)' ];
    if isProj % Projective camera
      if doK
        proj='projectivekap1kap2pp1pp2Ignored';
      else
        proj='projectivek1k2k3k4k5kap1kap2pp1pp2Ignored';
      end
    else % Affine camera
      if doK
        proj='affinetr3k4k5kap1kap2pp1pp2Ignored';
      else
        proj='affinetr3k1k2k3k4k5kap1kap2pp1pp2Ignored';
      end
    end
  end
  fullP = false;
else
  fullP = true;
  if isProj
    P0 = reshape( permute( P0, [ 2 1 3 ] ), [ 12 nFrame ] ); cnp=12;
    proj = 'projectiveFull';
  else
    P0 = reshape( permute( P0(1:2,:,:), [ 2 1 3 ] ), [ 8 nFrame ] ); cnp=8;
    proj = 'affineFull';
  end
  P0 = [ P0(:)' S0(:)' ];
  pnp = 3;
end

% Initialize the point variables
x = permute( W, [ 1 3 2 ]); x = x(:);

projac=[ proj 'Jac' projPath ];
proj=[ proj projPath ];

if ~isempty(covx)
  [ ret P info ] = sba( nPoint, nFrame, nFrameFixed, WMask, ...
    P0, cnp, pnp, x, covx, 2, proj, projac, nItrSBA, 0, [], 'motstr', ...
    K0, KMask );
else
  if sfmCase==Inf % NRSFM
    isFirstCoeff1=double(isFirstCoeff1);
    nFrameFixed = 0;
    [ ret P info ] = sba( nPoint, nFrame, nFrameFixed, WMask, ...
      P0, cnp, pnp, x, 2, proj, projac, nItrSBA, 0, [], 'motstr',isFirstCoeff1,...
      nBasis);
  else
% nPoint
% nFrame
% size(WMask)
% size(P0)
% cnp
% pnp
% size(x)
% nItrSBA
% size(K0)
% size(KMask)
% find(isnan(WMask'))
% find(isnan(x'))
% find(isnan(P0))
% proj
% projac
% K0
% KMask
      [ ret P info ] = sba( nPoint, nFrame, nFrameFixed, WMask, ...
        P0, cnp, pnp, x, 2, proj, projac, nItrSBA, 0, [], 'motstr',...
        K0, KMask );
  end
end

%  info(1:2)
%  info(1:2)/nFrame
if fullP
  if isProj
    P1 = permute( reshape( P(1:12*nFrame ), [ 4 3 nFrame ] ), [ 2 1 3 ] );
    S = reshape( P(12*nFrame + 1 : end ), 3, nPoint );
  else
    P1 = permute( reshape( P(1:8*nFrame ), [ 4 2 nFrame ] ), [ 2 1 3 ] );
    P1(3,4,:) = 1;
    S = reshape( P(8*nFrame + 1 : end ), 3, nPoint );
  end
  P = P1; K = zeros(3,3,nFrame); R = K; t = zeros(3,nFrame);
  for i = 1 : nFrame
    [ K(:,:,i) R(:,:,i) t(:,i) ] = extractFromP(P(:,:,i),isProj);
  end
else
  K=K0;
  if isProj % Projective camera
    P1 = reshape( P(1:(7+nK)*nFrame ), [], nFrame );
    R = quaternion( P1(1:4,:) );
    t = P1(5:7,:);
    K( ~KMask, : ) = P1( 8:end, : );
    S = reshape( P(( 7 + nK)*nFrame + 1 : end ), 3, nPoint );
  else % Affine camera
    if sfmCase~=Inf
      P1 = reshape( P(1:(6+nK)*nFrame ), [], nFrame );
      R = quaternion( P1(1:4,:) );
      t = P1(5:6,:); t(3,:) = 0;
      K( ~KMask, : ) = P1( 7:end, : );
      S = reshape( P(( 6 + nK)*nFrame + 1 : end ), 3, nPoint );
    else
      P1 = reshape( P(1:(6 + size(l,1))*nFrame ), [], nFrame );
      R = quaternion( P1(1:4,:) );
      t = P1(5:6,:); t(3,:) = 0;
      l = P1( 7 : end, : );
      S = permute( reshape( P(( 6 + size(l,1))*nFrame + 1 : end ), 3, ...
        nBasis, nPoint ), [ 1 3 2 ] );
    end
  end

  % Compute the final projection matrices
  Pi0 = eye(3,4); if ~isProj; Pi0(3,3:4) = [ 0 1 ]; end
  P = zeros( 3, 4, nFrame );
  KTmp = K; K = zeros(3,3,nFrame); K(3,3,:) = 1;
  for i=1:nFrame
    K(1,1:2,i) = KTmp(1:2,i); K(2,2,i) = KTmp(3,i);
    if isProj; K(1:2,3,i) = KTmp(4:5,i); end
    P(:,:,i) = K(:,:,i)*Pi0*[ R(:,:,i) t(:,i); 0 0 0 1 ];
  end
end
