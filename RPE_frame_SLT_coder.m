function [LARc, Nc,bc,CurrFrmExFull,CurrFrmSTResd] = RPE_frame_SLT_coder(s0, PrevFrmSTResd)
[LARc, CurrFrmSTResd] = RPE_frame_ST_coder(s0);
s0 = CurrFrmSTResd;
%% init vars
d = zeros(1,120);
Nc = zeros(1,4);
DLB = [0.2 0.5 0.8];
bc = zeros(1,4);

%% Prediction
prevd = PrevFrmSTResd(40:160);
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
prevd = [PrevFrmSTResd(80:160)' CurrFrmSTResd(1:40)'];

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
prevd = [PrevFrmSTResd(120:160)' CurrFrmSTResd(1:80)'];

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
CurrFrmExFull(:) = s0 - CurrFrmSTResd;
% Plot
% figure(1)
% clf
% plot(CurrFrmExFull)
% hold on
% title('e')

end
