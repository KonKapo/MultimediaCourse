[frame, Fs] = audioread('car.wav');
l = length(frame);
n=floor(l/160);
s0 = zeros(n*160,1);
PrevFrmSTResd = zeros(1,160)';
Nv = zeros(n*4,1);
errors = zeros(n,1);
cfs = zeros(n,1);
for i = 1:n
    s1 = frame(((i-1)*160+1:(i*160)));
    [LARc, Nc,bc,CurrFrmExFull, CurrFrmSTResd] = RPE_frame_SLT_coder(s1,PrevFrmSTResd);
    errors(i)=std(CurrFrmExFull);
    cfs(i)=std(CurrFrmSTResd);
    Nv(i*4-3:i*4)=Nc;
    [s0((i-1)*160+1:(i*160)), CurrFrmSTResd] = RPE_frame_SLT_decoder(LARc,Nc,bc, CurrFrmExFull,PrevFrmSTResd);
    PrevFrmSTResd = CurrFrmSTResd';
end
audiowrite('car4.wav',s0,Fs)

figure(3)
plot(s0)
hold on
plot(frame(1:n*160))
legend('s0','frame')
title('Decoded signal and frame comparison')
figure()
stem(cfs)
figure()
histogram(Nv)
figure()
histogram(errors.^2./cfs.^2)