function [N,b] = RPE_subframe_LTE(d,Prevd)

%% Input
% d vectors   lentgh 40
% Prevd is d' lentgh 120

%% Output
% N pitch period
% b Amplification factor

%% 3.1.13 page 25 Estimation
% 1)
R = xcorr(Prevd,d, 80);
R = R(81:end);
% 2)
[~,N] = max(R);
R2 = sum(Prevd(end-38-N:end-N+1));
% 3)
if R2~=0
    b = R(N)/R2^2;
else
    b=0;
end
end
