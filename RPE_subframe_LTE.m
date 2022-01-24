function [N,b] = RPE_subframe_LTE(d,Prevd)

%% Input
% d vectors   lentgh 40
% Prevd is d' lentgh 120

%% Output
% N pitch period
% b Amplification factor

%% Init Variables
lamda_max = length(Prevd);
subframe_size = len(d);
R = zeros(1,lamda_max-subframe_size);
d_doubleStress = zeros(1,subframe_size);
d_Stress = zeros(1,subframe_size);

%% 3.1.13 page 25 Estimation
% 1)
for lamda = subframe_size:lamda_max
    R(lamda) = xcorr(d,Prevd(lamda-subframe_size+1:lamda));    
end

% 2)
[~,I] = max(R);
N = I+subframe_size-1;

% 3)
% b = R(N)/(sum(Prevd((end-N):(end-N+39))^2))
b = R(N)/xcorr(Prevd(N-subframe_size+1:N));

%% 3.1.16 page 27 Prediction
for k=1:subframe_size
    if ( k < N )
        d_doubleStress(k) = b.*Prevd(subframe_size -N+k);
    else
        d_doubleStress(k) = d(k-N); %when Prevd ends and we take values from the current frame
        %nomizo thne xreiazetai
    end
end
e = d-d_doubleStress;

%% 3.1.17 Synthesis
for k=1:subframe_size
    d_Stress(k) = e(k) + d_doubleStress(k);
end


end

