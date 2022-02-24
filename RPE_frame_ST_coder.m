function [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(s0)
% Short Term Analysis Coder
%% init vars
frame = preprocessing(s0);
frame = postprocessing(frame);

%frame = s0;
l = length(frame);
d_1D = zeros(1,l);
d = zeros(9,l);
u = zeros(9,l);
ACF = zeros(1,9);
LAR = zeros(8,1);
LARc = zeros(8,1);
A = [20 20 20 20 13.637 15 8.334 8.824];
B = [0 0 4 -5 0.184 -3.5 -0.666 -2.235];

%% ACF, R and r estimations

for k = 1:9
    ACF(k)=sum(frame(k:end).*frame(1:end-k+1));                             %ACF calculation 3.1.4
end
R = ACF(1:end-1);
R = toeplitz(R);
r = ACF(2:end)';
w = mldivide(R,r);
r = poly2rc([1 -w(1) -w(2) -w(3) -w(4) -w(5) -w(6) -w(7) -w(8)]);
r = r/(max(abs(r)));
for i=1:8
    if(abs(r(i))<0.675)
        LAR(i) = r(i);
    elseif(abs(r(i))>=0.675 && abs(r(i))<0.975)
        LAR(i)=sign(r(i))*(2*abs(r(i)) - 0.675);
    else
        LAR(i)=sign(r(i))*(8*abs(r(i)) - 6.375);
    end

    z = A(i)*LAR(i)+B(i);
    integ=abs(floor(z));
    fract=abs(z)-abs(integ);
    if(abs(fract)==0.5)
        LARc(i) = z-sign(z)*0.5;
    else
        LARc(i)=round(z);
    end
end

if(LARc(1)<-32)
    LARc(1)=-32;
elseif(LARc(2)<-32)
    LARc(2)=-32;
elseif(LARc(3)<-16)
    LARc(3)=-16;
elseif(LARc(4)<-16)
    LARc(4)=-16;
elseif(LARc(5)<-8)
    LARc(5)=-8;
elseif(LARc(6)<-8)
    LARc(6)=-8;
elseif(LARc(7)<-4)
    LARc(7)=-4;
elseif(LARc(8)<-4)
    LARc(8)=-4;
elseif(LARc(1)>31)
    LARc(1)=31;
elseif(LARc(2)>31)
    LARc(2)=31;
elseif(LARc(3)>15)
    LARc(3)=15;
elseif(LARc(4)>15)
    LARc(4)=15;
elseif(LARc(5)>7)
    LARc(5)=7;
elseif(LARc(6)>7)
    LARc(6)=7;
elseif(LARc(7)>3)
    LARc(7)=3;
elseif(LARc(8)>3)
    LARc(8)=3;
end
% LARc
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
r = rc2poly(r);

for k = 1:l
    %% 3.1.11
    d(1,k) = frame(k);
    u(1,k) = frame(k);
    for i=2:9
        if (k == 1)
            d(i,k) = d(i-1,k);
            u(i,k) = u(i-1,k);
        else
            d(i,k) = d(i-1,k) + r(i-1) * u(i-1,k-1);
            u(i,k) = u(i-1,k) + r(i-1) * d(i-1,k);
        end
    end
    d_1D(k) = d(9,k);
end
CurrFrmSTResd = frame-d_1D';
% s_est = conv(frame,w,'same');

% % Plot
% figure(1)
% clf
% plot(frame)
% hold on
% plot(d_1D)
% legend('s_est','frame')
% title('s Estimation and frame comparison')
end

