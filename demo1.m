[frame, Fs] = audioread('car.wav');
s0 = zeros(128000,1);
e=zeros(800,1);
PrevLARc=zeros(8,1);
for i = 1:800
    [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(frame((i-1)*160+1:(i*160)));
    s0((i-1)*160+1:(i*160)) = RPE_frame_ST_decoder(LARc, CurrFrmSTResd);
    PrevLARc=LARc;
    e(i) = std(s0((i-1)*160+1:(i*160)) - frame((i-1)*160+1:(i*160)));
end
audiowrite('car2.wav',s0,Fs)

figure(1)
plot(s0,'y')
hold on
plot(frame,'c')
legend('s0','frame')
title('Decoded signal and frame comparison')
figure(2)
stem(e)
std(e)