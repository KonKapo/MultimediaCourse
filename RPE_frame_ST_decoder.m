function [s0] = RPE_frame_ST_decoder(LARc, PrevFrmResd)
% Short Term Analysis Decoder

%% init vars
frame = PrevFrmResd;
l = length(frame);
s_pred = zeros(1,l);
A = [20 20 20 20 13.637 15 8.334 8.824];
B = [0 0 4 -5 0.184 -3.5 -0.666 -2.235];
r = zeros(8,1);

for i=1:8
    z = LARc;
    %% 3.1.8 page 23
    LAR_doubleStress(i) = (z(i) - B(i))/A(i);
    %% 3.1.9
    LAR_Stress = LAR_doubleStress;
    %% 3.1.10
    % equation (3.5)
    if(abs(LAR_Stress(i))<0.675)
        r(i) = LAR_Stress(i);
    elseif(abs(LAR_Stress(i))>=0.675 && abs(LAR_Stress(i))<1.225)
        r(i)=sign(LAR_Stress(i))*(0.5*abs(LAR_Stress(i)) + 0.3375);
    else
        r(i)=sign(LAR_Stress(i))*(0.125*abs(LAR_Stress(i)) + 0.796875);
    end
end
r = rc2poly(r);
s_pred = filter(r, 1, frame')+frame; 
%% 3.2.4
s0 = postprocessing(s_pred);
end

