[frame, Fs] = audioread('car.wav');
MinLARc = [-32 -32 -16 -16 -8 -8 -4 -4];
MaxLARc = [31 31 15 15 7 7 3 3];
s0 = zeros(128000,1);
for i = 1:1
[LARc,  CurrFrmSTResd]= findLARc(frame((i-1)*160+1:(i*160)));
s0((i-1)*160+1:(i*160)) = RPE_frame_ST_decoder(LARc, CurrFrmSTResd);
end

audiowrite('car2.wav',s0,Fs)
figure(3)
plot(s0)
hold on
plot(frame)
legend('s0','frame')
title('Decoded signal and frame comparison')