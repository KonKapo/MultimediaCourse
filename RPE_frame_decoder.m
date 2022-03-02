function [s0, CurrFrmResd] = RPE_frame_decoder(FrmBitStrm, PrevFrmResd)
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

LARc(1) = bit2int(FrmBitStrm(1:6),6);
LARc(2) = bit2int(FrmBitStrm(7:12),6);
LARc(3) = bit2int(FrmBitStrm(13:17),5);
LARc(4) = bit2int(FrmBitStrm(18:22),5);
LARc(5) = bit2int(FrmBitStrm(23:26),4);
LARc(6) = bit2int(FrmBitStrm(27:30),4);
LARc(7) = bit2int(FrmBitStrm(31:33),3);
LARc(8) = bit2int(FrmBitStrm(34:36),3);

Nc(1) = bit2int(FrmBitStrm(37:43),7);
Nc(2) = bit2int(FrmBitStrm(93:99),7);
Nc(3) = bit2int(FrmBitStrm(149:155),7);
Nc(4) = bit2int(FrmBitStrm(205:211),7);

bc(1) = bit2int(FrmBitStrm(44:45),2);
bc(2) = bit2int(FrmBitStrm(100:101),2);
bc(3) = bit2int(FrmBitStrm(156:157),2);
bc(4) = bit2int(FrmBitStrm(212:213),2);


Mc(1) = bit2int(FrmBitStrm(46:47),2);
Mc(2) = bit2int(FrmBitStrm(102:103),2);
Mc(3) = bit2int(FrmBitStrm(158:159),2);
Mc(4) = bit2int(FrmBitStrm(214:215),2);

xMax(1) = bit2int(FrmBitStrm(48:53),6);
xMax(2) = bit2int(FrmBitStrm(104:109),6);
xMax(3) = bit2int(FrmBitStrm(160:165),6);
xMax(4) = bit2int(FrmBitStrm(216:221),6);

for l = 1:4
    for j = 1:13
        if(xb((l-1)*38+j+1) == 0 && xb((l-1)*38+j+2) == 0 && xb((l-1)*38+j+3) == 0)
            x_tone(l,j)=-28672;
        elseif(xb((l-1)*38+j+1) == 1 && xb((l-1)*38+j+2) == 0 && xb((l-1)*38+j+3) == 0)
            x_tone(l,j)=-20480;
        elseif(xb((l-1)*38+j+1) == 0 && xb((l-1)*38+j+2) == 1 && xb((l-1)*38+j+3) == 0)
            x_tone(l,j)=-12288;
        elseif(xb((l-1)*38+j+1) == 1 && xb((l-1)*38+j+2) == 1 && xb((l-1)*38+j+3) == 0)
            x_tone(l,j)=-4096;
        elseif(xb((l-1)*38+j+1) == 0 && xb((l-1)*38+j+2) == 0 && xb((l-1)*38+j+3) == 1)
            x_tone(l,j)=4096;
        elseif(xb((l-1)*38+j+1) == 1 && xb((l-1)*38+j+2) == 0 && xb((l-1)*38+j+3) == 1)
            x_tone(l,j)=12288;
        elseif(xb((l-1)*38+j+1) == 0 && xb((l-1)*38+j+2) == 1 && xb((l-1)*38+j+3) == 1)
            x_tone(l,j)=20480;
        elseif(xb((l-1)*38+j+1) == 1 && xb((l-1)*38+j+2) == 1 && xb((l-1)*38+j+3) == 1)
            x_tone(l,j)=28672;                     
        end
    end
end
x_tone = x_tone./2^15;

% Short Long Term Analysis Decoder
pred=zeros(1,160);
%% Init Vars
QLB = [0.1 0.35 0.65 1];
b = zeros(1,4);

%% Step 1 - Decoding of the LTP gains + LARcs
% N
N = Nc;
% b
b(:) = QLB(bc(:)+1);
prevd = PrevFrmResd(41:160);
pred(1:40)= b(1)*prevd(1+end-39-N(1):40+end-39-N(1))';

prevd = [PrevFrmResd(81:160)' pred(1:40)];
pred(41:80)= b(2)*prevd(1+end-39-N(2):40+end-39-N(2));

prevd = [PrevFrmResd(121:160)' pred(1:80)];
pred(81:120)= b(3)*prevd(1+end-39-N(3):40+end-39-N(3));
prevd = pred(1:120);
pred(121:160)= b(4)*prevd(1+end-39-N(4):40+end-39-N(4));
CurrFrmResd=CurrFrmExFull+pred;
% plot(pred)
s0 = RPE_frame_ST_decoder(LARc, CurrFrmResd);

end