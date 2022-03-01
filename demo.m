[frame, Fs] = audioread('car.wav');
s0 = zeros(800*160,1);
PrevFrmSTResd = zeros(1,160)';
for i = 1:800
    CurrFrmSTResd = frame(((i-1)*160+1:(i*160)));
    [LARc, Nc,bc,CurrFrmExFull, CurrFrmSTResd] = RPE_frame_SLT_coder(CurrFrmSTResd,PrevFrmSTResd);
    [s0((i-1)*160+1:(i*160)), CurrFrmSTResd] = RPE_frame_SLT_decoder(LARc,Nc,bc, CurrFrmExFull,PrevFrmSTResd);
    e(i) = std(frame((i-1)*160+1:(i*160)) - s0((i-1)*160+1:(i*160)));
    PrevFrmSTResd = CurrFrmSTResd';
end
audiowrite('car2.wav',s0,Fs)
figure(3)
plot(s0)
hold on
plot(frame(1:800*160))
legend('s0','frame')
title('Decoded signal and frame comparison')
e = s0 - frame(1:800*160);
figure()
stem(e)