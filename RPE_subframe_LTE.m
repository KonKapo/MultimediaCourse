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
% for lamda = subframe_size:lamda_max
%     R(lamda-subframe_size+1) = sum(d(:).*Prevd(lamda-subframe_size+1:lamda));    
% end
R = xcorr(Prevd,d, 80);
R = R(81:end);
% 2)
[~,N] = max(R);

% 3)
% b = R(N)/(sum(Prevd((end-N):(end-N+39))^2))
b = R(N)/sum(Prevd(N:N+subframe_size).*Prevd(N:N+subframe_size));

%% 3.1.16 page 27 Prediction
d_doubleStress(:) = b*Prevd(N+1:N+subframe_size);
e = d-d_doubleStress;

%% 3.1.17 Synthesis
for k=1:subframe_size
    d_Stress(k) = e(k) + d_doubleStress(k);
end


end

