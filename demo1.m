[frame, Fs] = audioread('car.wav');
s0 = zeros(128000,1);
for i = 1:800
    [LARc, CurrFrmSTResd] = RPE_frame_ST_coder(frame((i-1)*160+1:(i*160)));
    s0((i-1)*160+1:(i*160)) = RPE_frame_ST_decoder(LARc, CurrFrmSTResd);
end
audiowrite('car2.wav',s0/max(abs(s0)),Fs)

figure(1)
clf
a = s0/max(abs(s0));
plot(a,'r')
hold on
b = frame/max(abs(frame));
plot(b,'c')
legend('Reconstructed Signal s0','Initial Signal')
title('Decoded signal and frame comparison')

e = frame/(max(abs((frame)))) - s0/(max(abs(s0)));
figure(2)
clf
plot(e)
legend('Reconstructed Signal - Initial Signal')
title('Normalised Reconstruction Error')

e2 = frame - s0;
figure(3)
clf
plot(e2)
legend('Reconstructed Signal - Initial Signal')
title('Reconstruction Error')

se = e/sqrt(length(s0));
figure(4)
clf
plot(se)
legend('Reconstructed Signal - Initial Signal')
title('Reconstruction Standard Error')

pRMS = rms(se).^2
% Power of the Reconstruction Standard Error
% 3.2468e-08
energy = sum(se.^2)
% Energy of the Reconstruction Standard Error
% 0.0042

figure(5)
clf
obw(frame,1000e7)
figure(6)
clf
obw(frame)
% figure(5)
% clf
% plot(obw(frame))
% title('99% Occupied Bandwidth')








