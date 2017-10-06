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
snr_dB = 17:0.5:22;
cnt = 1;
Frame_errors = 0;

EsNo = 10.^(snr_dB/10);
amplitude = sqrt(EsNo);

%% For Loop for valid SNR region in 0.5 SNR steps
%
for l = 1:length(snr_dB)
    pause(1);
frames = 100000;   
%% Encoder using LDPC
% WiMax supports code rates of 1/2, 2/3, 3/4 and 5/6  and a code length of
% 576 upto 2304

[H_rows, H_cols, P] = InitializeWiMaxLDPC(rate, n);                   % creating LP-H-Matrix r x n

k = length( H_cols) - length(P);



for iterations = 1:frames                                                  % number of tested frames

   
    data = round(rand(1,k));


    codeword = LdpcEncode(data, H_rows, P);                                % codewords c

%% Mapping
QPSK = CreateConstellation( 'QAM', 64);                                       % QAM, PSK, FSK, etc. possible

symbols = Modulate(codeword,QPSK);

symbols_A = symbols;

%% channel (AWGN)

variance = 1/(2*EsNo(l));

noise = sqrt(variance)*(randn(size(symbols))+1i*randn(size(symbols)));
%(1/sqrt(2))*(randn(size(symbols))+1i*randn(size(symbols))); 
        %sqrt(variance)*(randn(size(symbols))+1i*randn(size(symbols))); 

r = symbols_A + noise;

%% Demapping using ML, Loglikelihood calculation

sym_ll = Demod2D(r, QPSK , EsNo(l));                                          % transforms received symbols into log-likelihoods

llr = Somap(sym_ll);                                                       % soft demapping



%% Decoder
% 50 iterations for code correction. At least 1 error in last iteration
% gives out a Frame_error
% FER = Frame_errors/(number of frames/iterations)
[output, errors] = MpDecode(-llr, H_rows, H_cols, 50, 0, 1, 1, data );     % decoder


if (errors(50) > 0)
    Frame_errors = Frame_errors + 1;
end

if (Frame_errors == 100)                                                   % premature break after 100 errors                                                  
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
inter = linspace(17,22,50000);
pFER = interp1(snr_dB,Frame_error_rate,inter);
snr_FER = find(pFER < 0.001);
snr_FER = snr_FER(1)/10000 + 17;

save('FER_5_6_QAM64_001_2.mat','Frame_error_rate');
save('FER_plot_5_6_QAM64_001_2.fig','sem');
save('snr_FER_5_6_QAM64_001_2.mat','snr_FER');

toc;