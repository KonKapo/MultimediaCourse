[frame, Fs] = audioread('car.wav');
% MinLARc = [-32 -32 -16 -16 -8 -8 -4 -4];
% MaxLARc = [31 31 15 15 7 7 3 3];
s0 = zeros(128000,1);
for i = 1:800
    [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(frame((i-1)*160+1:(i*160)));
    s0((i-1)*160+1:(i*160)) = RPE_frame_ST_decoder(LARc, CurrFrmSTResd);
end
max(abs(frame))
audiowrite('car2.wav',s0*abs(max(frame)),Fs)

figure(3)
plot(s0*max(abs(frame)))
hold on
plot(frame)
legend('s0','frame')
title('Decoded signal and frame comparison')
e = frame - s0*abs(max(frame));
figure()
std(e)