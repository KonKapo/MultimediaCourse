function [s0, CurrFrmResd] = RPE_frame_SLT_decoder(LARc,Nc,bc,CurrFrmExFull, PrevFrmResd)
% Short Long Term Analysis Decoder

%% Step 1 - ???? Na ginei sosta o apokvantismos
N = Nc;
b = bc;

%% Step 2 - 3.1.17 Synthesis

% 3.1.16 page 27 Prediction
d_doubleStress(:) = b*PrevFrmResd(N:N+subframe_size-1);
e = d-d_doubleStress;

d_Stress(:) = e(:) + b*d_doubleStress(:);

%e_r_Stress sto long term synthesis filter 3.1.16-3.1.17 producing d_r_Stress
%% !!!!!!!!!!!!!! 3.1.15 kai 3.1.16 na ginei me tin sosti seira oi praxeis kai na ginei 4 fores


%% 3.2.3 Short Term synthesis filtering section

for k = 1:l
    s_r(1,k) = d_1D(k);
    for i=1:8
        if(k==1)
            s_r(i+1,k)=s_r(i,k);
            v(10-i,k)=r(9-i) * s_r(i+1,k);
        elseif(k~=1)
            s_r(i+1,k) = s_r(i,k) - (r(9-i) * v(9-i,k-1));
            v(10-i,k) = v(9-i,k-1) + (r(9-i) * s_r(i+1,k));
        end
    end
    s_r_1D(k) = s_r(9,k);
    v(1,k) = s_r(9,k);
end

%% 3.2.4 Postprocessing
s0 = postprocessing(sro);

end

