function [N,b] = RPE_subframe_LTE(d,Prevd)

%% Input
% d vectors   lentgh 40
% Prevd is d' lentgh 120

%% Output
% N pitch period
% b Amplification factor

%% Init Variables
lamda_max = length(Prevd);
subframe_size = length(d);
R = zeros(1,lamda_max-subframe_size);
d_doubleStress = zeros(subframe_size, 1);
d_Stress = zeros(subframe_size, 1);

%% 3.1.13 page 25 Estimation
% 1)
R = xcorr(Prevd,d, 80);
R = R(81:end);
% 2)
[~,N] = max(R);
% 3)
b = R(N)/sum(Prevd(N:N+subframe_size-1).*Prevd(N:N+subframe_size-1));
end
