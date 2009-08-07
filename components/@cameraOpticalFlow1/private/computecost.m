function cost = computecost(Vx_OF,Vy_OF,Trajectories)
%% Omar Oreifej - 7/23/2009
%% Calculate Error for candidate trajectories

FIELD_X = 200;
FIELD_Y = 200;
MaxError = (FIELD_X.*FIELD_Y.*2);

%% Test every candidate trajectory
for index=1:size(Trajectories,2)
    Traj = Trajectories(index);
    
    % Generate potential rotation field
    T = [0 0 0];
    R = Trajectories(index).Rotation;
    f = Trajectories(index).f;
    Vxr= zeros(FIELD_Y,FIELD_X);
    Vyr = zeros(FIELD_Y,FIELD_X);
    Z = 50*ones(FIELD_Y,FIELD_X); % assuming constant depth
    for i=1:FIELD_Y
        for j=1:FIELD_X
            % get coordiantes with respect to center of image
            y=(i - FIELD_Y./2);
            x=(j - FIELD_X./2);

            A = [-f,0,x;0,-f,y];
            B = [(x.*y)./f , -(f+(x.^2)./f),y;(f+(y.^2)./f),-x.*y./f,-x];
            P = 1./ Z(i,j);
            V = P*A*T' + B*R';
            Vxr(i,j) = V(1);
            Vyr(i,j) = V(2);
        end;
    end;

    %% Generate potential translation direction field
    T = Trajectories(index).Translation;
    T = [T(2) T(1) T(3)];
    R = [0 0 0];
    f = Trajectories(index).f;
    Vxt= zeros(FIELD_Y,FIELD_X);
    Vyt = zeros(FIELD_Y,FIELD_X);
    Z = 50*ones(FIELD_Y,FIELD_X); % assuming constant depth
    for i=1:FIELD_Y
        for j=1:FIELD_X  
            % get coordiantes with respect to center of image
            y=(i - FIELD_Y./2);
            x=(j - FIELD_X./2);

            A = [-f,0,x;0,-f,y];
            B = [(x.*y)./f , -(f+(x.^2)./f),y;(f+(y.^2)./f),-x.*y./f,-x];
            P = 1./ Z(i,j);
            V = P*A*T' + B*R';
            Vxt(i,j) = V(1);
            Vyt(i,j) = V(2);
        end;
    end;
    % Drop magnitude of translation
    mag = (Vxt.^2 + Vyt.^2).^.5;
    if (mag~=0)
        Vxt = Vxt./mag;
        Vyt = Vyt./mag;
    end;

    % remove rotation effect
    Vx_OFT = (Vx_OF - Vxr);
    Vy_OFT = (Vy_OF - Vyr);

    % Drop magnitude and keep direction only
    mag = (Vx_OFT.^2 + Vy_OFT.^2).^.5;
    Vx_OFTD = Vx_OFT./mag;
    Vy_OFTD = Vy_OFT./mag;

    % remove NaNs
    Vx_OFTD(find(isnan(Vx_OFTD)==1)) =0;
    Vy_OFTD(find(isnan(Vy_OFTD)==1)) =0;

    % Calculate Error
    ErrorX = (Vx_OFTD - Vxt);
    ErrorY = (Vy_OFTD - Vyt);
    ErrorMag = (ErrorX.^2 + ErrorY.^2).^.5;
    cost(index) = sum(sum(ErrorMag))./MaxError;
end;
