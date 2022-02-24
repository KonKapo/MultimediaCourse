function [s0] = RPE_frame_ST_decoder(LARc, PrevFrmResd)
% Short Term Analysis Decoder

%% init vars
frame = PrevFrmResd;
l = length(frame);
d_1D = zeros(1,l);
d = zeros(9,l);
u = zeros(9,l);
s_r = zeros(8,l);
v = zeros(9,l);
s_r_1D = zeros(1,l);
A = [20 20 20 20 13.637 15 8.334 8.824];
B = [0 0 4 -5 0.184 -3.5 -0.666 -2.235];
r = zeros(8,1);

for i=1:8
    z = LARc;
    %% 3.1.8 page 23
    LAR_doubleStress(i) = (z(i) - B(i))/A(i);
    %% 3.1.9
    LAR_Stress = LAR_doubleStress;
    %% 3.1.10
    % equation (3.5)
    if(abs(LAR_Stress(i))<0.675)
        r(i) = LAR_Stress(i);
    elseif(abs(LAR_Stress(i))>=0.675 && abs(LAR_Stress(i))<1.225)
        r(i)=sign(LAR_Stress(i))*(0.5*abs(LAR_Stress(i)) + 0.3375);
    else
        r(i)=sign(LAR_Stress(i))*(0.125*abs(LAR_Stress(i)) + 0.796875);
    end
end

for k = 1:l
    %% 3.1.11
    d(1,k) = frame(k);
    u(1,k) = frame(k);
    for i=2:9
        if (k == 1)
            d(i,k) = d(i-1,k);
            u(i,k) = u(i-1,k) ;
        else
            d(i,k) = d(i-1,k) + r(i-1) * u(i-1,k-1) ;
            u(i,k) = u(i-1,k) + r(i-1) * d(i-1,k) ;
        end
    end
    d_1D(k) = d(9,k);
end

% figure(2)
% plot(d_1D)
% hold on
% plot(frame)
% hold on
% legend('d_1D','frame')
% title('frame, d_1D')

for k = 1:l
    s_r(1,k) = d_1D(k);
    for i=1:8
        if(k==1)
            s_r(i+1,k)=s_r(i,k);
            v(10-i,k)=r(9-i) * s_r(i+1,k);
        elseif(k~=1)
            s_r(i+1,k) = s_r(i,k) - (r(9-i) * v(9-i,k-1));
            v(10-i,k) = v(9-i,k-1) + (r(9-i) * s_r(i+1,k));
        end
    end
    s_r_1D(k) = s_r(9,k);
    v(1,k) = s_r(9,k);
end

%% 3.2.4
s0=s_r_1D/max(abs(s_r_1D));
end

