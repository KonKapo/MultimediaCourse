function [FrmBitStrm, CurrFrmResd] = RPE_frame_coder(s0,PrevFrmResd,PrevLARc)
% [LARc,Nc,bc,CurrFrmExFull,CurrFrmSTResd]  = RPE_frame_SLT_coder(s0, PrevFrmResd);

%[LARc, CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)to add
% Additions 3.1.9 implementation

% Short Term Analysis Coder

%% init vars
frame = s0;
l = length(frame);
s_pred = zeros(1,l);
ACF = zeros(1,9);
LAR = zeros(8,1);
LARc = zeros(8,1);
LAR_Stress = zeros(8,4);
FrmBitStrm = zeros(260,1);
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
[PrevLARc, ~] = RPE_frame_ST_coder(s0); %na figei lathos
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
CurrFrmSTResd = frame-s_pred';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(sum(PrevFrmResd==0)~=160)
    s0 = CurrFrmSTResd;
    %% init vars
    Nc = zeros(1,4);
    DLB = [0.2 0.5 0.8];
    bc = zeros(1,4);
    
    %% Prediction
    prevd = PrevFrmResd(40:160);
    [N,b] = RPE_subframe_LTE(s0(1:40),prevd);
    Nc(1)=N;
    
    %% 3.1.15 sub-segment number 1
    if (b<=DLB(1))
        bc(1)=0;
    elseif (DLB(1)<b && b<=DLB(2))
        bc(1)=1;
    elseif(DLB(2)<b && b<=DLB(3))
        bc(1)=2;
    elseif(DLB(3)<b)
        bc(1)=3;
    end
    %% 3.1.16 sub-segment number 1
    CurrFrmSTResd(1:40)= bc(1)*prevd(Nc(1):Nc(1)+39)';
    prevd = [PrevFrmResd(80:160)' CurrFrmSTResd(1:40)'];
    
    %% 3.1.15 sub-segment number 2
    [N,b] = RPE_subframe_LTE(s0(41:80),prevd');
    Nc(2)=N;
    if (b<=DLB(1))
        bc(2)=0;
    elseif (DLB(1)<b && b<=DLB(2))
        bc(2)=1;
    elseif(DLB(2)<b && b<=DLB(3))
        bc(2)=2;
    elseif(DLB(3)<b)
        bc(2)=3;
    end
    %% 3.1.16 sub-segment number 2
    CurrFrmSTResd(41:80)= bc(2)*prevd(Nc(2):Nc(2)+39);
    prevd = [PrevFrmResd(120:160)' CurrFrmSTResd(1:80)'];
    
    %% 3.1.15 sub-segment number 3
    [N,b] = RPE_subframe_LTE(s0(81:120),prevd');
    Nc(3)=N;
    
    if (b<=DLB(1))
        bc(3)=0;
    elseif (DLB(1)<b && b<=DLB(2))
        bc(3)=1;
    elseif(DLB(2)<b && b<=DLB(3))
        bc(3)=2;
    elseif(DLB(3)<b)
        bc(3)=3;
    end
    %% 3.1.16 sub-segment number 3
    CurrFrmSTResd(81:120)= bc(3)*prevd(Nc(3):Nc(3)+39);
    
    %% 3.1.15 sub-segment number 4
    [N,b] = RPE_subframe_LTE(s0(121:160), CurrFrmSTResd(1:120));
    Nc(4)=N;
    if (b<=DLB(1))
        bc(4)=0;
    elseif (DLB(1)<b && b<=DLB(2))
        bc(4)=1;
    elseif(DLB(2)<b && b<=DLB(3))
        bc(4)=2;
    elseif(DLB(3)<b)
        bc(4)=3;
    end
    %% 3.1.16 sub-segment number 4
    CurrFrmSTResd(121:160)= bc(4)*prevd(Nc(4):Nc(4)+39);
else
    Nc = [1 1 1 1];
    bc = [1 1 1 1];
end
CurrFrmExFull(:) = s0 - CurrFrmSTResd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CurrFrmResd = CurrFrmSTResd;
H = [-134 -374 0 2054 5471 8192 5471 2054 0 -374 -134];
H = H / 2^13;
x = zeros(160,1);
Mc = zeros(4,1);
xMax = zeros(4,1);

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
        %E_M
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
    
    for l = 1:4
        x_tone(l,:) = x(l+40*j:3:40*j+40-4+l)'/x_max;
    end
    xMax(j+1) = x_maxc;
end

x_tone = x_tone.*2^15;
for l = 1:4
    for j = 1:13
        if(x_tone(l,j)<=-24577)
            x_tone(l,j) = -28672;
        elseif(x_tone(l,j)>=-24576 && x_tone(l,j)<=-16385)
            x_tone(l,j) = -20480;
        elseif(x_tone(l,j)>=-16384 && x_tone(l,j)<=-8193)
            x_tone(l,j) = -12288;
        elseif(x_tone(l,j)>=-8192 && x_tone(l,j)<=-1)
            x_tone(l,j) = -4096;
        elseif(x_tone(l,j)>=0 && x_tone(l,j)<=8191)
            x_tone(l,j) = 4096;
        elseif(x_tone(l,j)>=8192 && x_tone(l,j)<=16384)
            x_tone(l,j) = 12288;
        elseif(x_tone(l,j)>=16385 && x_tone(l,j)<=24575)
            x_tone(l,j) = 20480;
        elseif(x_tone(l,j)>=24576 && x_tone(l,j)<=32767)
            x_tone(l,j) = 28672;
        end
    end
end

% 1.7 Bitstream sequence page 13
LARb = zeros(36,1); % 8 LARs with 6 6 5 5 4 4 3 3 bits
Nb = zeros(28,1); % 4 subframes with 7 bits each b37-b43 b93-b99 b149-b155 b205-b211
bb = zeros(8,1); % 4 subframes with 2 bits each b44-b45 b100-b101 b156-b157 b212-b213
Mb = zeros(8,1); % 4 subframes with 2 bits each b46-b47 b102-b103 b158-b159 b214-b215
xMaxb = zeros(24,1); % 4 subframes with 6 bits each b48-b53 b104-b109 b160-b165 b216-b221
xb = zeros(4*3*13,1); % 4 subframes with 12 pulses 3 bits each b54-b92 b110-b148 b166-b204 b222-b260

LARb(1:6) = bitget(LARc(1),6:-1:1,'int16');
LARb(7:12) = bitget(LARc(2),6:-1:1,'int16');
LARb(13:17) = bitget(LARc(3),5:-1:1,'int16');
LARb(18:22) = bitget(LARc(4),5:-1:1,'int16');
LARb(23:26) = bitget(LARc(5),4:-1:1,'int16');
LARb(27:30) = bitget(LARc(6),4:-1:1,'int16');
LARb(31:33) = bitget(LARc(7),3:-1:1,'int16');
LARb(34:36) = bitget(LARc(8),3:-1:1,'int16');
Nb(1:7) = bitget(Nc(1),7:-1:1,'int16');
Nb(8:14) = bitget(Nc(2),7:-1:1,'int16');
Nb(15:21) = bitget(Nc(3),7:-1:1,'int16');
Nb(22:28) = bitget(Nc(4),7:-1:1,'int16');
bb(1:2) = bitget(bc(1),2:-1:1,'int16');
bb(3:4) = bitget(bc(2),2:-1:1,'int16');
bb(5:6) = bitget(bc(3),2:-1:1,'int16');
bb(7:8) = bitget(bc(4),2:-1:1,'int16');
Mb(1:2) = bitget(Mc(1),2:-1:1,'int16');
Mb(3:4) = bitget(Mc(2),2:-1:1,'int16');
Mb(5:6) = bitget(Mc(3),2:-1:1,'int16');
Mb(7:8) = bitget(Mc(4),2:-1:1,'int16');
xMaxb(1:6) = bitget(xMax(1),6:-1:1,'int16');
xMaxb(7:12) = bitget(xMax(2),6:-1:1,'int16');
xMaxb(13:18) = bitget(xMax(3),6:-1:1,'int16');
xMaxb(19:24) = bitget(xMax(4),6:-1:1,'int16');

%table 3.6 page 31
for l = 1:4
    for j = 1:13
        if(x_tone(l,j)==-28672)
            xb((l-1)*38+j+1) = 0;
            xb((l-1)*38+j+2) = 0;
            xb((l-1)*38+j+3) = 0;
        elseif(x_tone(l,j)==-20480)
            xb((l-1)*38+j+1) = 1;
            xb((l-1)*38+j+2) = 0;
            xb((l-1)*38+j+3) = 0;
        elseif(x_tone(l,j)==-12288)
            xb((l-1)*38+j+1) = 0;
            xb((l-1)*38+j+2) = 1;
            xb((l-1)*38+j+3) = 0;
        elseif(x_tone(l,j)==-4096)
            xb((l-1)*38+j+1) = 1;
            xb((l-1)*38+j+2) = 1;
            xb((l-1)*38+j+3) = 0;
        elseif(x_tone(l,j)==4096)
            xb((l-1)*38+j+1) = 0;
            xb((l-1)*38+j+2) = 0;
            xb((l-1)*38+j+3) = 1;
        elseif(x_tone(l,j)==12288)
            xb((l-1)*38+j+1) = 1;
            xb((l-1)*38+j+2) = 0;
            xb((l-1)*38+j+3) = 1;
        elseif(x_tone(l,j)==20480)
            xb((l-1)*38+j+1) = 0;
            xb((l-1)*38+j+2) = 1;
            xb((l-1)*38+j+3) = 1;
        elseif(x_tone(l,j)==28672)
            xb((l-1)*38+j+1) = 1;
            xb((l-1)*38+j+2) = 1;
            xb((l-1)*38+j+3) = 1;
        end     
  end
end
% pairs of x_i(1:12)
% xb(1:39) = -> x1(:)
% xb(40:78) = -> x2(:)
% xb(79:117) = -> x3(:)
% xb(118:156) = -> x4(:)

FrmBitStrm=[LARb'...
    Nb(1:7)' bb(1:2)' Mb(1:2)' xMaxb(1:6)' xb(1:39)'...
    Nb(8:14)' bb(3:4)' Mb(3:4)' xMaxb(7:12)' xb(40:78)'...
    Nb(15:21)' bb(5:6)' Mb(5:6)' xMaxb(13:18)' xb(79:117)'...
    Nb(22:28)' bb(7:8)' Mb(7:8)' xMaxb(19:24)' xb(118:156)'];
end
