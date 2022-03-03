function [LARc, Nc,bc,CurrFrmExFull,CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)
[LARc, CurrFrmSTResd] = RPE_frame_ST_coder(s0);
pred = zeros(160,1);
QLB = [0.1 0.35 0.65 1];
Nc = zeros(1,4);
bc = zeros(1,4);
%% Prediction
prevd = PrevFrmSTResd(41:160);
[N,b] = RPE_subframe_LTE(CurrFrmSTResd(1:40),prevd);
Nc(1)=N;
bc(1) = quantb(b);
b = QLB(bc(1)+1);
%% 3.1.16 sub-segment number 1
pred(1:40)= b*prevd(1+end-39-N:40+end-39-N)';
prevd = [PrevFrmSTResd(81:160)' pred(1:40)'];
%% 3.1.15 sub-segment number 2
[N,b] = RPE_subframe_LTE(CurrFrmSTResd(41:80),prevd');
Nc(2)=N;
bc(2) = quantb(b);
b = QLB(bc(2)+1);
%% 3.1.16 sub-segment number 2
pred(41:80)= b*prevd(1+end-39-N:40+end-39-N);
prevd = [PrevFrmSTResd(121:160)' pred(1:80)'];
%% 3.1.15 sub-segment number 3
[N,b] = RPE_subframe_LTE(CurrFrmSTResd(81:120),prevd');
Nc(3)=N;
bc(3) = quantb(b);
b = QLB(bc(3)+1);
%% 3.1.16 sub-segment number 3
pred(81:120)= b*prevd(1+end-39-N:40+end-39-N);
%% 3.1.15 sub-segment number 4
[N,b] = RPE_subframe_LTE(CurrFrmSTResd(121:160), pred(1:120));
Nc(4)=N;
bc(4) = quantb(b);
b = QLB(bc(4)+1);
%% 3.1.16 sub-segment number 4
pred(121:160)= b*pred(1+end-79-N:40+end-79-N);
CurrFrmExFull(:) = CurrFrmSTResd - pred;
std(CurrFrmExFull)
% figure(1)
% hold on
% plot(pred, 'b')
end
