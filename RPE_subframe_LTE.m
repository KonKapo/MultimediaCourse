function [N,b] = RPE_subframe_LTE(d,Prevd)

%% Input
% d vectors   lentgh 40
% Prevd is d' lentgh 120

%% Output
% N pitch period
% b Amplification factor

%% 3.1.13 page 25 Estimation
R=zeros(80,1);
for k = 1:80
    R(k)=sum(d(:).*Prevd(1+end-39-k:40+end-39-k));
end
[~,N] = max(R);
R2 = sum(Prevd(1+end-39-N:40+end-39-N).*Prevd(1+end-39-N:40+end-39-N));
if R2~=0
    b = R(N)/R2;
else
    b=0;
end
end
