[frame, Fs] = audioread('car.wav');
l = length(frame);
n=floor(l/160);
s0 = zeros(n*160,1);
PrevFrmSTResd = zeros(1,160)';
e = zeros(n,1);
cfs = zeros(n,1);
for i = 1:n
    s1 = frame(((i-1)*160+1:(i*160)));
    [FrmBitStrm, CurrFrmResd] = RPE_frame_coder(s1,PrevFrmSTResd);
    [s0((i-1)*160+1:(i*160)), CurrFrmSTResd] = RPE_frame_decoder(FrmBitStrm, PrevFrmSTResd);
    e(i) = std(s1 - s0((i-1)*160+1:(i*160)));
    cfs(i) = std(s1);
    PrevFrmSTResd = CurrFrmSTResd';
end
audiowrite('car3.wav',s0,Fs)
figure()
plot(s0)
hold on
plot(frame(1:800*160))
legend('s0','frame')
title('Decoded signal and frame comparison')
figure()
stem(e)
figure()
histogram(e.^2./cfs.^2)