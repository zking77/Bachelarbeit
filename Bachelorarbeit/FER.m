%% Frame Error Rate for QPSK
%  Calculate the frame error rate with LDPC Encode/Decoding done with the
%  CM-Library.


%% Initialization
%addpath('Bachelorarbeit/cml/');
%CmlStartup;
clear all;
tic;
h = waitbar(0,'Calculating...');
n = 2304;                                                                   % 576:96:2304
rate = (5/6);
ind = 0;
% R = k/n
snr_dB = 4:0.5:10;
cnt = 1;
Frame_errors = 0;

EsNo = 10.^(snr_dB/10);

%% Loop
%
for l = 1:length(snr_dB)
    pause(1);
frames = 10000;   
%% Encoder
[H_rows, H_cols, P] = InitializeWiMaxLDPC(rate, n);                        % creating H-Matrix r x n

k = length( H_cols) - length(P);

for iterations = 1:frames
data = round(rand(1,k));

codeword = LdpcEncode(data, H_rows, P);                                    % codewords c

%% Mapping
QPSK = CreateConstellation( 'QPSK');                                       % QAM, PSK, FSK, etc. possible

symbols = Modulate(codeword,QPSK);

% channel

variance = 1/(2*EsNo(l));

noise = sqrt(variance)*(randn(size(symbols))+1i*randn(size(symbols))); 

r = symbols + noise;

%% Demapping
sym_ll = Demod2D(r, QPSK, EsNo);                                           % transforms received symbols into log-likelihoods

llr = Somap(sym_ll);                                                       % soft demapping



%% Decoder
[output, errors] = MpDecode(-llr, H_rows, H_cols, 50, 0, 1, 1, data );     % decoder

if (errors(50) > 0)
    Frame_errors = Frame_errors + 1;
end

if (Frame_errors == 100)
    break;
end

end
Frame_error_rate(l) = Frame_errors/iterations;
Frame_errors = 0;
waitbar(l/length(snr_dB));
end
close(h);
figure;
sem = semilogy(snr_dB,Frame_error_rate);
inter = linspace(4,10,6000);
pFER = interp1(snr_dB,Frame_error_rate,inter);
snr_FER = find(pFER < 0.01);
snr_FER = snr_FER(1)/1000 + 4;

save('FER_7_8.mat','Frame_error_rate');
save('FER_plot_7_8.fig','sem');
save('snr_FER_7_8.mat','snr_FER');

toc;