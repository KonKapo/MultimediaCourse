[frame, Fs] = audioread('car.wav');
s0 = zeros(800*160,1);
PrevFrmSTResd = zeros(1,160)';
for i = 1:800
    s1 = frame(((i-1)*160+1:(i*160)));
    [FrmBitStrm, CurrFrmResd] = RPE_frame_coder(s1,PrevFrmSTResd);
    %[s0((i-1)*160+1:(i*160)), CurrFrmSTResd] = RPE_frame_SLT_decoder(LARc,Nc,bc, CurrFrmExFull,PrevFrmSTResd);
    %e(i) = std(s1 - s0((i-1)*160+1:(i*160)));
    %PrevFrmSTResd = CurrFrmSTResd';
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