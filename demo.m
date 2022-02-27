[frame, Fs] = audioread('car.wav');
s0 = zeros(128000,1);
for i = 1:800
    CurrFrmSTResd = frame(((i-1)*160+1:(i*160)));
    if i == 1
        PrevFrmSTResd = zeros(1,160)';
        [LARc,Nc,bc,CurrFrmExFull,CurrFrmSTResd]= RPE_frame_SLT_coder(CurrFrmSTResd,PrevFrmSTResd);
    else
        [LARc,Nc,bc,CurrFrmExFull,CurrFrmSTResd]= RPE_frame_SLT_coder(CurrFrmSTResd,PrevFrmSTResd);
    end
    s0((i-1)*160+1:(i*160)) = RPE_frame_SLT_decoder(LARc,Nc,bc, CurrFrmExFull,CurrFrmSTResd);
    PrevFrmSTResd = CurrFrmSTResd;
end
audiowrite('car2.wav',s0,Fs)
figure(3)
plot(s0*abs(max(frame))/2)
hold on
plot(frame)
legend('s0','frame')
title('Decoded signal and frame comparison')
e = frame - s0*abs(max(frame));
figure()
std(e)