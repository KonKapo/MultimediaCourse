function [s0, CurrFrmResd] = RPE_frame_SLT_decoder(LARc,Nc,bc,CurrFrmExFull, PrevFrmResd)
% Short Long Term Analysis Decoder

%% Init Vars
QLB = [0.1 0.35 0.65 1];
b = zeros(1,4);
subframe_size = 40;

%% Step 1 - Decoding of the LTP gains + LARcs
% N
N = Nc;
% b
for i = 1:4
    b(i) = QLB(i);
end
    
%% Step 2 - 3.1.17 Synthesis

% 3.1.16 page 27 Analysis
d_doubleStress(1:40) = b(1)*PrevFrmResd(N(1):N(1)+subframe_size-1);
d_doubleStress(41:80) = b(2)*PrevFrmResd(N(2):N(2)+subframe_size-1);
d_doubleStress(81:120) = b(3)*PrevFrmResd(N(3):N(3)+subframe_size-1);
d_doubleStress(121:160) = b(4)*PrevFrmResd(N(4):N(4)+subframe_size-1);

e = CurrFrmExFull-d_doubleStress;

% 3.1.17 page 27 Synthesis
d_Stress(1:40) = e(1:40) + b(1)*d_doubleStress(1:40);
d_Stress(41:80) = e(41:80) + b(2)*d_doubleStress(41:80);
d_Stress(81:120) = e(81:120) + b(3)*d_doubleStress(81:120);
d_Stress(121:160) = e(121:160) + b(4)*d_doubleStress(121:160);
CurrFrmResd = d_Stress;

%% Steps 3, 4, 5 and 6 implemented in RPE_frame_ST_decoder
% Short Term Analysis Decoder
s0 = RPE_frame_ST_decoder(LARc, PrevFrmResd);


end
