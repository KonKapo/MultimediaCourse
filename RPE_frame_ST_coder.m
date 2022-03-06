function [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(s0, PrevLARc)
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
LARcmin = [-32 -32 -16 -16 -8 -8 -4 -4];
LARcmax = [31 31 15 15 7 7 3 3];


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
%     LAR(i) = log10((1+r(i))/(1-r(i)));
%     if(abs(r(i))>0.675)
%         s = 'bike'
%     end
    z = A(i)*LAR(i)+B(i);
    integ=abs(floor(z));
    fract=abs(z)-abs(integ);
    if(abs(fract)==0.5)
        LARc(i) = z-sign(z)*0.5;
    else
        LARc(i)=round(z);
    end
    if(LARc(i)<LARcmin(i))
        LARc(i) = LARcmin(i);
    elseif(LARc(i)>LARcmax(i))
        LARc(i) = LARcmax(i);
    end
end

% LARc
if(~exist('PrevLARc','var') || isempty(PrevLARc))  
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
    s_pred = filter(r, 1, frame');
else
    for i=1:8
        z = LARc;
        PrevZ = PrevLARc;
        %% 3.1.8 page 23
        LAR_doubleStress(i) = (z(i) - B(i))/A(i);
        PrevLAR_doubleStress(i) = (PrevZ(i) - B(i))/A(i);
        %% 3.1.9
        LAR_Stress(i,1) = 0.75*PrevLAR_doubleStress(i) + 0.25*LAR_doubleStress(i);
        LAR_Stress(i,2) = 0.5*PrevLAR_doubleStress(i) + 0.5*LAR_doubleStress(i);
        LAR_Stress(i,3) = 0.25*PrevLAR_doubleStress(i) + 0.75*LAR_doubleStress(i);
        LAR_Stress(i,4) = 0*PrevLAR_doubleStress(i) + 1*LAR_doubleStress(i);
        %% 3.1.10
        % equation (3.5)
        for k = 1:l
            for j = 1:4
                if(abs(LAR_Stress(i,j))<0.675)
                    r(i,j) = LAR_Stress(i,j);
                elseif(abs(LAR_Stress(i,j))>=0.675 && abs(LAR_Stress(i,j))<1.225)
                    r(i,j)=sign(LAR_Stress(i,j))*(0.5*abs(LAR_Stress(i,j)) + 0.3375);
                else
                    r(i,j)=sign(LAR_Stress(i,j))*(0.125*abs(LAR_Stress(i,j)) + 0.796875);
                end
            end
        end
        
    end
    
    a = -rc2poly(r(:,1));
    r(:,1) = a(2:end);
    a = -rc2poly(r(:,2));
    r(:,2) = a(2:end);
    a = -rc2poly(r(:,3));
    r(:,3) = a(2:end);
    a = -rc2poly(r(:,4));
    r(:,4) = a(2:end);
    
    for k = 1:l
        %% 3.1.11
        if (k<=13)
            s_pred(1:13) = filter(r(i,1), 1, frame(1:13)');
        elseif (k>13 && k<=27)
            s_pred(14:27) = filter(r(i,2), 1, frame(14:27)');
        elseif (k>27 && k<=40)
            s_pred(28:40) = filter(r(i,3), 1, frame(28:40)');
        else
            s_pred(41:end) = filter(r(i,4), 1, frame(41:end)');
        end
    end
end
CurrFrmSTResd = frame-s_pred';
end

