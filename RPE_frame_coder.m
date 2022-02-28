function [FrmBitStrm, CurrFrmResd] = RPE_frame_coder(s0,PrevFrmResd)
[LARc,Nc,bc,CurrFrmExFull,CurrFrmSTResd]  = RPE_frame_SLT_coder(s0, PrevFrmResd);

%[LARc, CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)to add
% Additions 3.1.9 implementation

% Short Term Analysis Coder

%% init vars
frame = s0;
l = length(frame);
s_pred = zeros(1,l);
d_1D = zeros(1,l);
d = zeros(9,l);
u = zeros(9,l);
ACF = zeros(1,9);
LAR = zeros(8,1);
LARc = zeros(8,1);
LAR_Stress = zeros(8,4);
r = zeros(8,4);
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

[PrevLARc, ~] = RPE_frame_ST_coder(s0);

% LARc
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
    LAR_Stress(i,4) = 0*PrevLAR_doubleStress(i) + 0.25*LAR_doubleStress(i);
    %% 3.1.10
    % equation (3.5)
    for k = 1:l
        if(abs(LAR_Stress(i,l))<0.675)
            r(i,l) = LAR_Stress(i,l);
        elseif(abs(LAR_Stress(i))>=0.675 && abs(LAR_Stress(i,l))<1.225)
            r(i,l)=sign(LAR_Stress(i,l))*(0.5*abs(LAR_Stress(i,l)) + 0.3375);
        else
            r(i,l)=sign(LAR_Stress(i,l))*(0.125*abs(LAR_Stress(i,l)) + 0.796875);
        end
    end
    
end
r(:,1) = -rc2poly(r(:,1));
r(:,2) = -rc2poly(r(:,2));
r(:,3) = -rc2poly(r(:,3));
r(:,4) = -rc2poly(r(:,4));

for k = 1:l
    %% 3.1.11
    d(1,k) = frame(k);
    u(1,k) = frame(k);
    for i=2:9
        if (k-i-1>0)
            if (k<=12)
                s_pred(k) = s_pred(k) + r(k)*frame(k-i-1);
            elseif (k>12 && k<=27)
                s_pred(k) = s_pred(k) + r(k)*frame(k-i-1);
            elseif (k>27 && k<=40)
                s_pred(k) = s_pred(k) + r(k)*frame(k-i-1);
            else
                s_pred(k) = s_pred(k) + r(k)*frame(k-i-1);
            end
        end
    end
end
CurrFrmSTResd = frame-s_pred';

CurrFrmResd = CurrFrmSTResd;
H = [-134 -374 0 2054 5471 8192 5471 2054 0 -374 -134];
H = H / 2^13;
x = zeros(160,1);
Mc = zeros(4,1);

for j = 0:3
    xm = zeros(4,1);
    for k = 1:40
        for i = 1:11
            if(k+6-i>40 || k+6-i<1)
                
            else
                x(k+40*j) = x(k+40*j) + H(i)*CurrFrmSTResd(40*j+k+6-i);
            end
        end
    end
    for l = 1:4
        xm(l)=sum(x(l+40*j:3:40*j+40-4+l).^2);
    end
    [~, Mc(j+1)] = max(xm);
    xmax = max(abs(x((Mc(j+1)+40*j:3:40*j+40-4+Mc(j+1)))));
    if(xmax>=0 && xmax<=511)
        x_maxc = floor((xmax)/32);
        x_max = x_maxc*32-1;
    elseif(xmax>=512 && xmax<=1023)
        x_maxc = floor((xmax-511)/64)+15;
        x_max = 511+x_maxc*64-1;
    elseif(xmax>=1024&& xmax<=2047)
        x_maxc = floor((xmax-1023)/128)+23;
        x_max = 1023+x_maxc*128-1;
    elseif(xmax>=2048 && xmax<=4095)
        x_maxc = floor((xmax-2047)/256)+31;
        x_max = 2047+x_maxc*256-1;
    elseif(xmax>=4096 && xmax<=8191)
        x_maxc = floor((xmax-4095)/512)+39;
        x_max = 4095+x_maxc*512-1;
    elseif(xmax>=8192 && xmax<=16383)
        x_maxc = floor((xmax-8191)/1024)+47;
        x_max = 8191+x_maxc*1024-1;
    elseif(xmax>=16384 && xmax<=32767)
        x_maxc = floor((xmax-16383)/2048)+55;
        x_max = 16384+x_maxc*2048-1;
    end
    x_tone=xmax/x_max;
    FrmBitStrm=0;
end
