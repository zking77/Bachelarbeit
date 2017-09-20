openfig('QPSK.fig');
hold on;
title('FER vs. Capacity of QPSK');
load('snr_FER_1_2.mat');
plot(snr_FER,1,'r*');
load('snr_FER_2_3.mat');
plot(snr_FER,(2*2/3),'r*');
load('snr_FER_3_4.mat');
plot(snr_FER,1.5,'r*');
load('snr_FER_5_6.mat');
plot(snr_FER,(2*5/6),'r*');

legend('QPSK','R = 1/2', 'R = 2/3', 'R = 3/4', 'R = 5/6');
xlim([-10,20]);
ylim([0, 2.5]);