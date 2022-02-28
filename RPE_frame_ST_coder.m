function [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(s0)
% Short Term Analysis Coder
%% init vars
frame = preprocessing(s0);

%frame = s0;
l = length(frame);
s_pred = zeros(1,l);
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
r2=w;
r = poly2rc([1 -w(1) -w(2) -w(3) -w(4) -w(5) -w(6) -w(7) -w(8)]);

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
r = -rc2poly(r);
mean(r(2:end)-r2');

for i = 1:160
    for k=2:9
        if (i-k-1>0)
            s_pred(i) = s_pred(i) + r(k)*frame(i-k-1);
        end
    end
end


CurrFrmSTResd = frame-s_pred';
end

