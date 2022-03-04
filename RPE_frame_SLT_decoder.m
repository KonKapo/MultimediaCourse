function [s0, CurrFrmResd] = RPE_frame_SLT_decoder(LARc,Nc,bc,CurrFrmExFull, PrevFrmResd)
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
% plot(CurrFrmResd+0.05)
s0 = RPE_frame_ST_decoder(LARc, CurrFrmResd);
end
