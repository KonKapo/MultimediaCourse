function [N,b] = RPE_subframe_LTE(d,Prevd)

%% Input
% d vectors   lentgh 40
% Prevd is d' lentgh 120

%% Output
% N pitch period
% b Amplification factor

%% 3.1.13 page 25 Estimation
% 1)
% R = xcorr(Prevd,d, 80);
% R = R(81:end);
R=zeros(80,1);
for k = 1:80
    R(k)=sum(d(:).*Prevd(1+end-39-k:40+end-39-k));
end
% 2)
[~,N] = max(R);
R2 = sum(Prevd(1+end-39-N:40+end-39-N));
% 3)
if R2~=0
    b = R(N)/R2^2;
else
    b=0;
end
end
