classdef SparseTrackerSURF < FastPBM.FastPBMConfig & FastPBM.SparseTracker
    
    properties (Constant = true, GetAccess = private)
        Fthresh = .0001;
    end
    
    properties (GetAccess = private, SetAccess = private)
        camera
        mask
        nodeA
        nodePrevious
        xA
        yA
        features
        uniqueIndex
        uniqueNext
        firstTrack
        figureHandle
        plotHandle
        numLevels
    end
    
    methods (Access = public, Static = true)
        function this = SparseTrackerSURF(initialTime, camera)
            this = this@FastPBM.SparseTracker(initialTime);
            
            % store camera handle
            this.camera = camera;
            
            if(~exist([fileparts(mfilename('fullpath')),filesep,'private',filesep,'MEXSURF.',mexext],'file'))
                
                % Locate OpenCV libraries
                fprintf('\nSparseTrackerSURF: Mexing SURF...');
                userPath = path;
                userWarnState = warning('off', 'all'); % see MATLAB Solution ID 1-5JUPSQ
                addpath(getenv('LD_LIBRARY_PATH'), '-END');
                addpath(getenv('PATH'), '-END');
                warning(userWarnState);
                if(ispc)
                    libdir=fileparts(which('cv110.lib'));
                    %libdir = fileparts(which('cv.lib'));
                elseif(ismac)
                    libdir = fileparts(which('libcv.dylib'));
                else
                    libdir = fileparts(which('libcv.so'));
                end
                path(userPath);
                
                % Compile and link against OpenCV libraries
                userDirectory = pwd;
                cd(fullfile(fileparts(mfilename('fullpath')), 'private'));
                
                try
                    if(ispc)
                        mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcv110','-lcxcore110', '-lhighgui110', '-lcvaux110');
                        %mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcvd','-lcxcored', '-lhighguid', '-lcvauxd');
                    elseif(ismac)
                        mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcv','-lcxcore', '-lhighgui', '-lcvaux');
                    else
                        mex('MEXSURF.cpp',['-L"',libdir,'"'],'-lcv','-lcxcore', '-lhighgui', '-lcvaux');
                    end
                catch err
                    details =['mex fail' err.message];
                    cd(userDirectory);
                    error(details);
                end
                cd(userDirectory);
                fprintf('Done\n');
            end
            
            this.firstTrack = true;
            this.track();
        end
    end
    
    methods (Abstract = false, Access = public, Static = false)
        function refresh(this, x)
            this.camera.refresh(x);
            this.track();
        end
        
        function flag = hasData(this)
            flag = this.camera.hasData();
        end
        
        function n = first(this)
            n = this.camera.first();
        end
        
        function n = last(this)
            n = this.camera.last();
        end
        
        function time = getTime(this, n)
            time = this.camera.getTime(n);
        end
        
        function flag = isFrameDynamic(this)
            flag = this.camera.isFrameDynamic();
        end
        
        function pose = getFrame(this, node)
            pose = this.camera.getFrame(node);
        end
        
        function num = numFeatures(this, node)
            num = numel(this.features(node-this.nodeA+uint32(1)).id);
        end
        
        function id = getFeatureID(this, node, localIndex)
            id = this.features(node-this.nodeA+uint32(1)).id(localIndex+uint32(1));
        end
        
        function ray = getFeatureRay(this, node, localIndex)
            ray = this.features(node-this.nodeA+uint32(1)).ray(:, localIndex+uint32(1));
        end
    end
    
    methods (Access=private)
        % perform tracking
        function track(this)
            
            % only attempt to track if the camera has data
            if(this.camera.hasData())
                if(this.firstTrack)
                    this.nodeA = this.camera.first();
                    this.nodePrevious = this.nodeA;
                end
                
                % if there are any new images
                nodeLast = this.camera.last();
                nodeB = this.nodePrevious+uint32(1);
                if(nodeLast>=nodeB)
                    
                    % process all new images
                    for nodeB = nodeB:nodeLast
                        
                        im1 = double(rgb2gray(this.camera.getImage(this.nodeA)));
                        im2 = double(rgb2gray(this.camera.getImage(nodeB)));
                        [r1 r2] = MEXSURF(im1, im2, double(.8));
                        
                        matches=[];
                        matches(:,1)=r1(:,1)+1;
                        matches(:,2)=r1(:,2)+1;
                        matches(:,3)=r2(:,1)+1;
                        matches(:,4)=r2(:,2)+1;
                        p1 = [matches(:,1:2)]';
                        p2 = [matches(:,3:4)]';
                        [F, inliers] = ransacfitfundmatrix(p1, p2, this.Fthresh,0);
                        matches = matches(inliers,:);
                        
                        this.yA=matches(:,1)';
                        this.xA=matches(:,2)';
                        yB=matches(:,3)';
                        xB=matches(:,4)';                        
                        
                        % optionally display tracking results
                        if(this.displayFeatures)
                            if(isempty(this.figureHandle))
                                this.figureHandle = figure;
                            else
                                figure(this.figureHandle);
                                if(~isempty(this.plotHandle))
                                    delete(this.plotHandle);
                                end
                            end
                            imshow(this.camera.getImage(this.nodeA), []);
                            axis('image');
                            hold('on');
                            this.plotHandle = plot([this.yA; yB], [this.xA; xB], 'r');
                            drawnow;
                        end
                        
                        % store both tracked and new features
                        this.features(nodeB-this.nodeA).id = this.uniqueIndex;
                        this.features(nodeB-this.nodeA).ray = this.camera.inverseProjection([this.yA;this.xA]-1, this.nodeA);
                        
                        this.features(nodeB-this.nodeA+uint32(1)).id = this.uniqueIndex;
                        this.features(nodeB-this.nodeA+uint32(1)).ray = this.camera.inverseProjection([yB; xB]-1, nodeB);
                    end
                    this.nodePrevious = nodeB;
                end
            end
        end
        
        % randomly select new image features
        function [x, y] = selectFeatures(this, gx, gy, num)
            kappa = computeCornerStrength(gx, gy, 1, this.cornerMethod);
            [x, y] = findPeaks(kappa, this.halfwin, num);
        end
        
        % get unique indices
        function id = getUniqueIndices(this, num)
            if(isempty(this.uniqueNext))
                this.uniqueNext = uint32(0);
            end
            if(num>0)
                a = this.uniqueNext;
                b = a+uint32(num-1);
                id = a:b;
                this.uniqueNext = b+uint32(1);
            else
                id = zeros(1, 0, 'uint32');
            end
        end
        
        % Prepare an image for processing
        %
        % Computes number of pyramid levels if this.firstTrack is true
        % Gets an image from the camera
        % Converts to grayscale and normalizes to the range [0,1]
        % Applies NaN mask outside of the projection area
        % Pads the bottom and right sides with NaN based on pyramid levels (does not affect pixel coordinates)
        function img = prepareImage(this, node)
            if(this.firstTrack)
                steps = this.camera.numSteps();
                strides = this.camera.numStrides();
                [stepGrid, strideGrid] = ndgrid(0:(double(steps)-1), 0:(double(strides)-1));
                pix = [strideGrid(:)'; stepGrid(:)'];
                ray = this.camera.inverseProjection(pix,node);
                this.mask = find(isnan(ray(1, :)));
                pix = [double(strides)-2; double(steps)-1]/2;
                pix = [pix, pix+[1; 0]];
                ray = this.camera.inverseProjection(pix, node);
                angularSpacing = acos(dot(ray(:, 1), ray(:, 2)));
                maxPix = this.maxSearch/angularSpacing;
                this.numLevels = uint32(1+ceil(log2(maxPix/this.halfwin)));
                this.firstTrack = false;
            end
            img = this.camera.getImage(node);
            switch(this.camera.interpretLayers())
                case {'rgb', 'rgbi'}
                    img = double(rgb2gray(img(:, :, 1:3)))/255;
                case {'hsv', 'hsvi'}
                    img = double(img(:, :, 3))/255;
                otherwise
                    img = double(img)/255;
            end
            img(this.mask) = NaN;
            multiple = 2^(this.numLevels-1);
            [M, N] = size(img);
            Mpad = multiple-mod(M, multiple);
            Npad = multiple-mod(N, multiple);
            if((Mpad>0)||(Npad>0))
                img(M+Mpad, N+Npad) = 0; % allocates memory for padded image
            end
            if(Mpad>0)
                img((M+1):(M+Mpad), :) = NaN;
            end
            if(Npad>0)
                img(:, (N+1):(N+Npad)) = NaN;
            end
        end
    end
end

