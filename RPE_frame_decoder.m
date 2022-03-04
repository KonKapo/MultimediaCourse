function [s0, CurrFrmResd] = RPE_frame_decoder(FrmBitStrm, PrevFrmResd)
H = [-134 -374 0 2054 5471 8192 5471 2054 0 -374 -134];
H = H./2^13;
% FrmBitStrm=[LARb'...
%     Nb(1:7)' bb(1:2)' Mb(1:2)' xMaxb(1:6)' xb(1:39)'...
%     Nb(8:14)' bb(3:4)' Mb(3:4)' xMaxb(7:12)' xb(40:78)'...
%     Nb(15:21)' bb(5:6)' Mb(5:6)' xMaxb(13:18)' xb(79:117)'...
%     Nb(22:28)' bb(7:8)' Mb(7:8)' xMaxb(19:24)' xb(118:156)']
LARc = zeros(8,1);
Nc = zeros(4,1);
bc = zeros(4,1);
Mc = zeros(4,1);
xMax = zeros(4,1);
x_tone = zeros(4,13);
xd = zeros(160,1);
x = zeros(160,1);
LARc(1) = bin2dec(num2str(FrmBitStrm(1:6)));
LARc(2) = bin2dec(num2str((FrmBitStrm(7:12))));
LARc(3) = bin2dec(num2str((FrmBitStrm(13:17))));
LARc(4) = bin2dec(num2str((FrmBitStrm(18:22))));
LARc(5) = bin2dec(num2str((FrmBitStrm(23:26))));
LARc(6) = bin2dec(num2str((FrmBitStrm(27:30))));
LARc(7) = bin2dec(num2str((FrmBitStrm(31:33))));
LARc(8) = bin2dec(num2str((FrmBitStrm(34:36))));

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
Mc
for j = 1:4
    x_new(j,:) = x_tone2(j,:)* x_maxd(j);
    xd(Mc(j)+40*(j-1):3:40*(j-1)+40-4+Mc(j)) = x_new(j,:);
end
% for j =0:3
%     for k = 1:40
%         for i = 1:11
%             if(k+6-i>40 || k+6-i<1)
%                 
%             else
%                 x(k+40*j) = x(k+40*j) + H(i)*xd(40*j+k+6-i);
%             end
%         end
%     end
% end
x = xd./2^13;
[s0, CurrFrmResd] = RPE_frame_SLT_decoder(LARc,Nc,bc,x', PrevFrmResd);
end