function [FrmBitStrm, CurrFrmResd] = RPE_frame_coder(s0,PrevFrmResd)
[LARc, Nc,bc,CurrFrmExFull, CurrFrmResd] = RPE_frame_SLT_coder(s0,PrevFrmResd); %na fygei
x_tone = zeros(4,13);
e = CurrFrmExFull;
H = [-134 -374 0 2054 5471 8192 5471 2054 0 -374 -134];
x = zeros(160,1);
Mc = zeros(4,1);
xMax = zeros(4,1);
for j = 0:3
    xm = zeros(4,1);
    for k = 1:40
        for i = 1:11
            if(k+6-i<=40 && k+6-i>=1)
                x(k+40*j) = x(k+40*j) + H(i)*e(40*j+k+6-i);
            end
        end
    end
    for l = 1:4
        %E_M
        xm(l)=sum(x(l+40*j:3:40*j+40-4+l).^2);
    end
    [~, Mc(j+1)] = (max(xm));
    xmax = ceil(max(abs(x((Mc(j+1)+40*j:3:40*j+40-4+Mc(j+1))))));
    if(xmax>=0 && xmax<=511)
        x_maxc = floor((xmax)/32);
        x_max = (x_maxc+1)*32-1;
    elseif(xmax>=512 && xmax<=1023)
        x_maxc = floor((xmax-511)/64)+16;
        x_max = (x_maxc+1)*64-1;
    elseif(xmax>=1024&& xmax<=2047)
        x_maxc = floor((xmax-1023)/128)+24;
        x_max = (x_maxc+1)*128-1;
    elseif(xmax>=2048 && xmax<=4095)
        x_maxc = floor((xmax-2047)/256)+32;
        x_max = (x_maxc+1)*256-1;
    elseif(xmax>=4096 && xmax<=8191)
        x_maxc = floor((xmax-4095)/512)+40;
        x_max = (x_maxc+1)*512-1;
    elseif(xmax>=8192 && xmax<=16383)
        x_maxc = floor((xmax-8191)/1024)+48;
        x_max = (x_maxc+1)*1024-1;
    elseif(xmax>=16384 && xmax<=32767)
        x_maxc = floor((xmax-16383)/2048)+56;
        x_max = (x_maxc+1)*2048-1;
    end
    %x_tonei(:,j+1)=x((Mc(j+1)+40*j:3:40*j+40-4+Mc(j+1)))';
    x_tone(j+1,:) = x((Mc(j+1)+40*j:3:40*j+40-4+Mc(j+1)))'/x_max;
    xMax(j+1) = x_maxc;
end

x_tonec = x_tone.*2^15;
for l = 1:4
    for j = 1:13
        if(x_tonec(l,j)<=-24577&&x_tonec(l,j)>=-32767)
            x_tonec(l,j) = -28672;
        elseif(x_tonec(l,j)>=-24576 && x_tonec(l,j)<=-16395)
            x_tonec(l,j) = -20480;
        elseif(x_tonec(l,j)>=-16394 && x_tonec(l,j)<=-8193)
            x_tonec(l,j) = -12288;
        elseif(x_tonec(l,j)>=-8192 && x_tonec(l,j)<=-1)
            x_tonec(l,j) = -4096;
        elseif(x_tonec(l,j)>=0 && x_tonec(l,j)<=8191)
            x_tonec(l,j) = 4096;
        elseif(x_tonec(l,j)>=8192 && x_tonec(l,j)<=16394)
            x_tonec(l,j) = 12288;
        elseif(x_tonec(l,j)>=16395 && x_tonec(l,j)<=24575)
            x_tonec(l,j) = 20480;
        elseif(x_tonec(l,j)>=24576 && x_tonec(l,j)<=32767)
            x_tonec(l,j) = 28672;
        end
    end
end


% 1.7 Bitstream sequence page 13
LARb = zeros(36,1); % 8 LARs with 6 6 5 5 4 4 3 3 bits
Nb = zeros(28,1); % 4 subframes with 7 bits each b37-b43 b93-b99 b149-b155 b205-b211
bb = zeros(8,1); % 4 subframes with 2 bits each b44-b45 b100-b101 b156-b157 b212-b213
Mb = zeros(8,1); % 4 subframes with 2 bits each b46-b47 b102-b103 b158-b159 b214-b215
xMaxb = zeros(24,1); % 4 subframes with 6 bits each b48-b53 b104-b109 b160-b165 b216-b221
xb = zeros(4*3*13,1); % 4 subframes with 13 pulses 3 bits each b54-b92 b110-b148 b166-b204 b222-b260

%LARc(1)
if(LARc(1)>=0)
    LARb(1) = 0;
    LARb(2:6) = bitget(LARc(1),5:-1:1,'int16');
elseif(LARc(1)==-32)
    LARb(1:6) = bitget(-LARc(1),6:-1:1,'int16');
else
    LARb(1) = 1;
    LARb(2:6) = bitget(-LARc(1),5:-1:1,'int16');
end
%LARc(2)
if(LARc(2)>=0)
    LARb(7) = 0;
    LARb(8:12) = bitget(LARc(2),5:-1:1,'int16');
elseif(LARc(2)==-32)
    LARb(7:12) = bitget(-LARc(2),6:-1:1,'int16');
else
    LARb(7) = 1;
    LARb(8:12) = bitget(-LARc(2),5:-1:1,'int16');
end
%LARc(3)
if(LARc(3)>=0)
    LARb(13) = 0;
    LARb(14:17) = bitget(LARc(3),4:-1:1,'int16');
elseif(LARc(3)==-16)
    LARb(13:17) = bitget(-LARc(3),5:-1:1,'int16');
else
    LARb(13) = 1;
    LARb(14:17) = bitget(-LARc(3),4:-1:1,'int16');
end
%LARc(4)
if(LARc(4)>=0)
    LARb(18) = 0;
    LARb(19:22) = bitget(LARc(4),4:-1:1,'int16');
elseif(LARc(4)==-16)
    LARb(18:22) = bitget(-LARc(4),5:-1:1,'int16');
else
    LARb(18) = 1;
    LARb(19:22) = bitget(-LARc(4),4:-1:1,'int16');
end
%LARc(5)
if(LARc(5)>=0)
    LARb(23) = 0;
    LARb(24:26) = bitget(LARc(5),3:-1:1,'int16');
elseif(LARc(5)==-8)
    LARb(23:26) = bitget(-LARc(5),4:-1:1,'int16');
else
    LARb(23) = 1;
    LARb(24:26) = bitget(-LARc(5),3:-1:1,'int16');
end
%LARc(6)
if(LARc(6)>=0)
    LARb(27) = 0;
    LARb(28:30) = bitget(LARc(6),3:-1:1,'int16');
elseif(LARc(6)==-8)
    LARb(27:30) = bitget(-LARc(6),4:-1:1,'int16');
else
    LARb(27) = 1;
    LARb(28:30) = bitget(-LARc(6),3:-1:1,'int16');
end
%LARc(7)
if(LARc(7)>=0)
    LARb(31) = 0;
    LARb(32:33) = bitget(LARc(7),2:-1:1,'int16');
elseif(LARc(7)==-4)
    LARb(31:33) = bitget(-LARc(7),3:-1:1,'int16');
else
    LARb(31) = 1;
    LARb(32:33) = bitget(-LARc(7),2:-1:1,'int16');
end
%LARc(8)
if(LARc(8)>=0)
    LARb(34) = 0;
    LARb(35:36) = bitget(LARc(8),2:-1:1,'int16');
elseif(LARc(7)==-4)
    LARb(34:36) = bitget(-LARc(8),3:-1:1,'int16');
else
    LARb(34) = 1;
    LARb(35:36) = bitget(-LARc(8),2:-1:1,'int16');
end
Mc=Mc-1;
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

for l = 1:4
    for j = 1:13
        if(x_tonec(l,j)==-28672)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(0,3:-1:1,'int16');
        elseif(x_tonec(l,j)==-20480)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(4,3:-1:1,'int16');
        elseif(x_tonec(l,j)==-12288)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(2,3:-1:1,'int16');
        elseif(x_tonec(l,j)==-4096)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(6,3:-1:1,'int16');
        elseif(x_tonec(l,j)==4096)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(1,3:-1:1,'int16');
        elseif(x_tonec(l,j)==12288)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(5,3:-1:1,'int16');
        elseif(x_tonec(l,j)==20480)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(3,3:-1:1,'int16');
        elseif(x_tonec(l,j)==28672)
            xb((l-1)*39+3*j-2:(l-1)*39+3*j) = bitget(7,3:-1:1,'int16');
        end
    end
end


FrmBitStrm=[LARb'...
    Nb(1:7)' bb(1:2)' Mb(1:2)' xMaxb(1:6)' xb(1:39)'...
    Nb(8:14)' bb(3:4)' Mb(3:4)' xMaxb(7:12)' xb(40:78)'...
    Nb(15:21)' bb(5:6)' Mb(5:6)' xMaxb(13:18)' xb(79:117)'...
    Nb(22:28)' bb(7:8)' Mb(7:8)' xMaxb(19:24)' xb(118:156)'];
end
