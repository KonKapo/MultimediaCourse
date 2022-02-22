function [s0, CurrFrmResd] = RPE_frame_SLT_decoder(LARc,Nc,bc,CurrFrmExFull, PrevFrmResd)
% Short Long Term Analysis Decoder

%% Init Vars
QLB = [0.1 0.35 0.65 1];
b = zeros(1,4);

%% Step 1 - Decoding of the LTP gains + LARcs
% N
N = Nc;
% b
for i = 1:4
    b(i) = QLB(bc(i));
end
    
%% Step 2 - 3.1.17 Synthesis

% 3.1.16 page 27 Analysis
d_doubleStress(:) = b*CurrFrmExFull(N:N+subframe_size-1);
e = d-d_doubleStress;

% 3.1.17 page 27 Synthesis
d_Stress(:) = e(:) + b*d_doubleStress(:);
CurrFrmResd = d_Stress;

%% Steps 3, 4, 5 and 6 implemented in RPE_frame_ST_decoder
% Short Term Analysis Decoder
s0 = RPE_frame_ST_decoder(LARc, PrevFrmResd);


end
