function [LARc, Nc,bc,CurrFrmExFull,CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)
[LARc, CurrFrmSTResd] = RPE_frame_ST_coder(s0);
pred = zeros(160,1);
QLB = [0.1 0.35 0.65 1];
d = zeros(1,120);
Nc = zeros(1,4);
bc = zeros(1,4);
if(sum(PrevFrmSTResd==0)~=160)
    %% Prediction
    prevd = PrevFrmSTResd(40:160);
    [N,b] = RPE_subframe_LTE(CurrFrmSTResd(1:40),prevd);
    Nc(1)=N;
    %% 3.1.15 sub-segment number 1
    bc(1) = quantb(b);
    b = QLB(bc(1)+1);
    %% 3.1.16 sub-segment number 1
    pred(1:40)= b*prevd(1+end-39-N:40+end-39-N)';
    prevd = [PrevFrmSTResd(80:160)' pred(1:40)'];
    %% 3.1.15 sub-segment number 2
    [N,b] = RPE_subframe_LTE(CurrFrmSTResd(41:80),prevd');
    Nc(2)=N;
    bc(2) = quantb(b);
    b = QLB(bc(2)+1);
    %% 3.1.16 sub-segment number 2
    pred(41:80)= b*prevd(1+end-39-N:40+end-39-N);
    prevd = [PrevFrmSTResd(120:160)' pred(1:80)'];
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
    pred(121:160)= b*pred(1+end-39-N:40+end-39-N);
else
    Nc = [1 1 1 1];
    bc = [1 1 1 1];
end
CurrFrmExFull(:) = CurrFrmSTResd - pred;
std(CurrFrmExFull)
figure(1)
plot(CurrFrmSTResd)
hold on
end
