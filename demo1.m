[frame, Fs] = audioread('car.wav');
% [frame, Fs] = audioread('audiosample3.wav');
l = length(frame);
n=floor(l/160);
s0 = zeros(n*160,1);
L = zeros(n,8);
ek = zeros(n,1);
cfs = zeros(n,1);
prevLARc = zeros(8,1);
for i = 1:n
    [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(frame((i-1)*160+1:(i*160)), prevLARc);
    s0((i-1)*160+1:(i*160)) = RPE_frame_ST_decoder(LARc, CurrFrmSTResd);
    ek(i) = std(s0((i-1)*160+1:(i*160))-frame((i-1)*160+1:(i*160)));
    cfs(i)=std(frame((i-1)*160+1:(i*160)));
    L(i,:) = LARc;
    prevLARc = LARc;
end
audiowrite('car1.wav',s0,Fs)

figure(1)
clf
plot(s0,'r')
hold on
plot(frame,'c')
legend('Reconstructed Signal s0','Initial Signal')
title('Decoded Signal and Initial Signal comparison')

e2 = frame - s0;
figure(3)
clf
plot(e2)
legend('Reconstructed Signal - Initial Signal')
title('Reconstruction Error')

figure(4)
clf
stem(ek)
legend('Reconstructed Signal - Initial Signal')
title('Reconstruction Standard Error')

pRMS = rms(se).^2;
% Power of the Reconstruction Standard Error
% 3.2300e-08
energy = sum(se.^2);
% Energy of the Reconstruction Standard Error
% 0.0041


figure(5)
clf
obw(frame,1000e7)
figure(6)
clf
obw(frame)


figure(6)
clf
stem(L(:,1))
title('1st LARcs of every frame')
hold on;
yline(-32);
hold on;
yline(31);

figure(7)
clf
stem(L(:,2))
title('2nd LARcs of every frame')
hold on;
yline(-32);
hold on;
yline(31);

figure(8)
clf
stem(L(:,8))
title('8th LARcs of every frame')
hold on;
yline(-4);
hold on;
yline(3);

figure(9)
clf
stem(L(:,4))
title('4th LARcs of every frame')
hold on;
yline(-16);
hold on;
yline(15);

figure(10)
clf
histogram(L(:,1))
title("LARc(1) histogram")






