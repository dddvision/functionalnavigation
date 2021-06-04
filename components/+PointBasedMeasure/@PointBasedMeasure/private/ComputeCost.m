function [ cost ] = ComputeCost( data, testTrajectory, ErrorType, DisplayTestTrajectory )
% Copyright 2011 University of Central Florida, New BSD License

    % Constants
    MAX_ROTATION = 9.4248; %(3.*pi)
    MAX_TRANSLATION = 2;

    corrS = data.corrS;
    corrP = data.corrP;
    corrK = data.corrK;
    corrR = data.corrR;
    corrT = data.corrT;
    nonNormalizedMatches = data.nonNormalizedMatches;
    normalizedMatches = data.normalizedMatches;
    im_width = size(data.imageA,2);
    im_height = size(data.imageA,1);

    costs = [];
    
    %% ----------- Calcuate cost based on the computed SFM ----------------
    % prepare trajectory
    r1 = testTrajectory.Rotation;
    t1 = testTrajectory.Translation';
    
    switch(ErrorType)
        case 1
        [th1_2 th2_2 th3_2]=rotationMatrix(corrR(:,:,2));
        r2 = pi - [th1_2 th2_2 th3_2];
        if norm(t1)~=0
            t1 = t1./norm(t1);
        end
        t2 = corrT(:,2);
        if norm(t2)~=0
            t2 = t2./norm(t2);
        end
        
        % convert trajectory to forward-right-down from left-up-back
        t2=[-t2(3) -t2(1) -t2(2)];
        r2=[-r2(3) -r2(1) -r2(2)];

        costs(1) = ((norm(r1-r2)./MAX_ROTATION)+ (norm(t1-t2)./MAX_TRANSLATION))./2; 

        if(DisplayTestTrajectory)
            fprintf('\n           translation(given) = < ');
            fprintf('%f ',t1);
            fprintf('>');     
            fprintf('       translation(estimated) = < ');
            fprintf('%f ',t2);
            fprintf('>');
            fprintf('\ndifference(given:estimated) = < ');
            fprintf('%f ', t1-t2);
            fprintf('>');
        end
    
    %% Todo: Fix the point based measure variations below ...
    %% (Pending testing)
    
        case 2
        %type 2
        tmpErr2 = 0;
        R1 = GetRotMatrix2_omar(r1.*180./pi);
        P2 = corrK(:,:,2)*[R1 t1'];
        for pIndex=1:size(corrS,2)
            x21 = [nonNormalizedMatches(pIndex,3:4)]';
            x22 =P2*[corrS(:,pIndex);1];
            x22 = x22./x22(3);
            e = norm(x21 - x22(1:2));
            tmpErr2 = tmpErr2 + e;
        end;
        costs(2) = tmpErr2./size(corrS,2);
    
    
        case 3
        %type 3
        tmpErr3 = 0;
        tt1 = t1;
        Etest = skew(tt1)*R1;
        for pIndex=1:size(normalizedMatches,1)
            x1 =normalizedMatches(pIndex,1:2);
            x2 = normalizedMatches(pIndex,3:4);
            tmpErr3 = tmpErr3 + norm([x2 1]*Etest*[x1 1]');
        end;
        costs(3) = tmpErr3./size(normalizedMatches,1);
    
    
        case 4
        %type 4
        tmpErr4 = 0;
        P2 = corrK(:,:,2)*[R1 t1'];
        count = 0;
        for pIndex=1:size(corrS,2)
            x11 =round([nonNormalizedMatches(pIndex,1:2)]');
            x22 =P2*[corrS(:,pIndex);1];
            x22 = round(x22./x22(3));
            if (any(x22(1:2)' >[im_width im_height]) || any(x22(1:2)' <[1 1]))
                continue;
            end;
            intens1 = double(data.imageA(x11(2),x11(1)));
            intens2 = double(data.imageB(x22(2),x22(1)));
            e = norm( intens1- intens2);
            tmpErr4 = tmpErr4 + e;
            count = count+ 1;
        end;
        costs(4) = tmpErr4./count;
    
    
        case 5
        %type 5
        tmpErr5 = 0;
        P1 = corrK(:,:,1)*[eye(3,3), [0;0;0]];
        P2 = corrK(:,:,2)*[R1 t1'];
        for pIndex=1:size(corrS,2)
            x11 =[nonNormalizedMatches(pIndex,1:2)]';
            x21 =[nonNormalizedMatches(pIndex,3:4)]';
            % trangulate the points
            X = compute3D_omar(x11,x21,P1,P2);
            x12 = P1*X;
            x22 = P2*X;
            x12 = x12./x12(3);
            x22 = x22./x22(3);
            e = (norm(x11 - x12(1:2)) + norm(x21 - x22(1:2)))./2;
            tmpErr5 = tmpErr5 + e;
        end;
        costs(5) = tmpErr5./size(corrS,2);
    end

    
    
    cost = costs(ErrorType);

end

