function [s0, CurrFrmResd] = RPE_frame_decoder(FrmBitStrm, PrevFrmResd)
LARc = zeros(8,1);
Nc = zeros(4,1);
bc = zeros(4,1);
Mc = zeros(4,1);
xMax = zeros(4,1);
x_toned = zeros(4,13);
xd = zeros(160,1);

LARb = FrmBitStrm(1:36);
if(LARb(1)==0)
    LARc(1) = bin2dec(num2str(FrmBitStrm(2:6)));
elseif(FrmBitStrm(1)==1 && FrmBitStrm(2)==0 && FrmBitStrm(3)==0 && FrmBitStrm(4)==0 && FrmBitStrm(5)==0 && FrmBitStrm(6)==0)
    LARc(1) = -32;
elseif(LARb(1)==1)
    LARc(1) = -bin2dec(num2str(FrmBitStrm(2:6)));
end
if(LARb(7)==0)
    LARc(2) = bin2dec(num2str(FrmBitStrm(8:12)));
elseif(FrmBitStrm(7)==1 && FrmBitStrm(8)==0 && FrmBitStrm(9)==0 && FrmBitStrm(10)==0 && FrmBitStrm(11)==0 && FrmBitStrm(12)==0)
    LARc(2) = -32;
elseif(LARb(7)==1)
    LARc(2) = -bin2dec(num2str(FrmBitStrm(8:12)));
end

if(LARb(13)==0)
    LARc(3) = bin2dec(num2str(FrmBitStrm(14:17)));
elseif(FrmBitStrm(13)==1 && FrmBitStrm(14)==0 &&FrmBitStrm(15)==0 && FrmBitStrm(16)==0 && FrmBitStrm(17)==0 )
    LARc(3) = -16;
elseif(LARb(13)==1)
    LARc(3) = -bin2dec(num2str(FrmBitStrm(14:17)));
end

if(LARb(18)==0)
    LARc(4) = bin2dec(num2str(FrmBitStrm(19:22)));
elseif(FrmBitStrm(18)==1 && FrmBitStrm(19)==0 &&FrmBitStrm(20)==0 && FrmBitStrm(21)==0 && FrmBitStrm(22)==0 )
    LARc(4) = -16;
elseif(LARb(18)==1)
    LARc(4) = -bin2dec(num2str(FrmBitStrm(19:22)));
end

if(LARb(23)==0)
    LARc(5) = bin2dec(num2str(FrmBitStrm(24:26)));
elseif(FrmBitStrm(23)==1 && FrmBitStrm(24)==0 &&FrmBitStrm(25)==0 && FrmBitStrm(26)==0)
    LARc(5) = -8;
elseif(LARb(23)==1)
    LARc(5) = -bin2dec(num2str(FrmBitStrm(24:26)));
end

if(LARb(27)==0)
    LARc(6) = bin2dec(num2str(FrmBitStrm(28:30)));
elseif(FrmBitStrm(27)==1 && FrmBitStrm(28)==0 &&FrmBitStrm(29)==0 && FrmBitStrm(30)==0)
    LARc(6) = -8;
elseif(LARb(27)==1)
    LARc(6) = -bin2dec(num2str(FrmBitStrm(28:30)));
end

if(LARb(31)==0)
    LARc(7) = bin2dec(num2str(FrmBitStrm(32:33)));
elseif(FrmBitStrm(31)==1 && FrmBitStrm(32)==0 &&FrmBitStrm(33)==0)
    LARc(7) = -4;
elseif(LARb(31)==1)
    LARc(7) = -bin2dec(num2str(FrmBitStrm(32:33)));
end

if(LARb(34)==0)
    LARc(8) = bin2dec(num2str(FrmBitStrm(35:36)));
elseif(FrmBitStrm(34)==1 && FrmBitStrm(35)==0 &&FrmBitStrm(36)==0)
    LARc(8) = -4;
elseif(LARb(34)==1)
    LARc(8) = -bin2dec(num2str(FrmBitStrm(35:36)));
end

Nc(1) = bin2dec(num2str((FrmBitStrm(37:43))));
Nc(2) = bin2dec(num2str((FrmBitStrm(93:99))));
Nc(3) = bin2dec(num2str((FrmBitStrm(149:155))));
Nc(4) = bin2dec(num2str((FrmBitStrm(205:211))));

bc(1) = bin2dec(num2str((FrmBitStrm(44:45))));
bc(2) = bin2dec(num2str((FrmBitStrm(100:101))));
bc(3) = bin2dec(num2str((FrmBitStrm(156:157))));
bc(4) = bin2dec(num2str((FrmBitStrm(212:213))));


Mc(1) = bin2dec(num2str((FrmBitStrm(46:47))))+1;
Mc(2) = bin2dec(num2str((FrmBitStrm(102:103))))+1;
Mc(3) = bin2dec(num2str((FrmBitStrm(158:159))))+1;
Mc(4) = bin2dec(num2str((FrmBitStrm(214:215))))+1;

xMax(1) = bin2dec(num2str((FrmBitStrm(48:53))));
xMax(2) = bin2dec(num2str((FrmBitStrm(104:109))));
xMax(3) = bin2dec(num2str((FrmBitStrm(160:165))));
xMax(4) = bin2dec(num2str((FrmBitStrm(216:221))));

xb = [FrmBitStrm(54:92) FrmBitStrm(110:148) FrmBitStrm(166:204) FrmBitStrm(222:260)];

%synthesis
for j = 1:4
    if(xMax(j)<=15)
        x_maxd(j) = (xMax(j)+1)*32-1;
    elseif(xMax(j)>=5&&xMax(j)<=23)
        x_maxd(j) = (xMax(j)+1)*64-1;
    elseif(xMax(j)>23&& xMax(j)<=31)
        x_maxd(j) = (xMax(j)+1)*128-1;
    elseif(xMax(j)>31 && xMax(j)<=39)
        x_maxd(j) = (xMax(j)+1)*256-1;
    elseif(xMax(j)>39 && xMax(j)<=47)
        x_maxd(j) = (xMax(j)+1)*512;
    elseif(xMax(j)>47&&xMax(j)<=55)
        x_maxd(j) = (xMax(j)+1)*1024-1;
    else
        x_maxd(j) = (xMax(j)+1)*2048-1;
    end
end

for l = 1:4
    for j = 1:13
        if(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==0)
            x_toned(l,j)=-28672;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==4)
            x_toned(l,j)=-20480;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==2)
            x_toned(l,j)=-12288;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==6)
            x_toned(l,j)=-4096;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==1)
            x_toned(l,j)=4096;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==5)
            x_toned(l,j)=12288;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==3)
            x_toned(l,j)=20480;
        elseif(bin2dec(num2str(xb((l-1)*39+3*j-2:(l-1)*39+3*j)))==7)
            x_toned(l,j)=28672;
        end
    end
end

x_tone2 = x_toned./2^15;
for j = 1:4
    xd(Mc(j)+40*(j-1):3:40*(j-1)+40-4+Mc(j)) = x_tone2(j,:)* x_maxd(j);
end
x = xd./2^13;
plot(x)
[s0, CurrFrmResd] = RPE_frame_SLT_decoder(LARc,Nc,bc,x', PrevFrmResd);

end
