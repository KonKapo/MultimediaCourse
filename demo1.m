[frame, Fs] = audioread('car.wav');
s0 = zeros(128000,1);
for i = 1:800
    [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(frame((i-1)*160+1:(i*160)));
    s0((i-1)*160+1:(i*160)) = RPE_frame_ST_decoder(LARc, CurrFrmSTResd);
end
audiowrite('car2.wav',s0/max(abs(s0)),Fs)

figure(1)
plot(s0/max(abs(s0)),'y')
hold on
plot(frame/max(abs(frame)),'c')
legend('s0','frame')
title('Decoded signal and frame comparison')
e = frame/(max(abs((frame)))) - s0/(max(abs(s0)));
figure(2)
plot(e)
std(e)