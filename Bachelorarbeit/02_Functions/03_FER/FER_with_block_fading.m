%% Frame Error Rate for QPSK with block fading
%  Calculate the frame error rate with LDPC Encode/Decoding done with the
%  CM-Library.


%% Initialization
%addpath('Bachelorarbeit/cml/');
%CmlStartup;
clear all;
%estimate unknown fading
tic;
h = waitbar(0,'Calculating...');
n = 576;                                                                   % 576:96:2304
rate = (5/6);
ind = 0;
% R = k/n
snr_dB = 0:1:50;
cnt = 1;
Frame_errors = 0;

EsNo = 10.^(snr_dB/10);

%% Loop
%

for l = 1:length(snr_dB)
    pause(1);
frames = 100000;   
%% Encoder
[H_rows, H_cols, P] = InitializeWiMaxLDPC(rate, n);                        % creating H-Matrix r x n

k = length( H_cols) - length(P);

for iterations = 1:frames 
data = round(rand(1,k));

codeword = LdpcEncode(data, H_rows, P);                                    % codewords c

perm = randperm(length(codeword));

interleaver = intrlv(codeword,perm);
%% Mapping
QPSK = CreateConstellation( 'QPSK');                                       % QAM, PSK, FSK, etc. possible
symbols = [];
symbols = Modulate(interleaver,QPSK);

%% Split symbols into blocks

T = n/192;
sym_temp = [];
variance = 1/(2*EsNo(l));
amplitude = sqrt(EsNo(l));
j = 0;
for j = 1:1:(length(symbols)/T)
    
    fading = (1/sqrt(2))*(randn(1)+1i*randn(1));
    sym_temp(j,:) = symbols((j-1)*T+1:j*T);
    block_sym(j,:) = [1 sym_temp(j,:)];

%% channel
    noise = sqrt(1/2)*(randn(size(block_sym(1,:)))+1i*randn(size(block_sym(1,:)))); 

    r(j,:) = amplitude*block_sym(j,:)*fading + noise;


    est_fad = r(j,1)/amplitude;
    est_sym = r(j,:)/est_fad;
    l_sym = size(est_sym);
    
    real_sym(j,:) = est_sym(2:l_sym(2));
end
    receiv_sym = []; 
    receiv_sym = reshape(real_sym.',1,length(symbols));

% %% Demapping
x = amplitude*[1 1i -1i -1];
temp_snr = EsNo(l);
for s = 1:n/2
s1(s) = -(1/EsNo(l))*(abs(receiv_sym(s)-x(1)).^2);    %1
s2(s) = -(1/EsNo(l))*(abs(receiv_sym(s)-x(2)).^2);    
s3(s) = -(1/EsNo(l))*(abs(receiv_sym(s)-x(3)).^2);
s4(s) = -(1/EsNo(l))*(abs(receiv_sym(s)-x(4)).^2);

if(s2(s)<s1(s))
    if(s4(s)<s3(s))

        L_y(1+(2*(s-1))) = (s1(s)+log(1+exp(s2(s)-s1(s))))-(s3(s)+log(1+exp(s4(s)-s3(s))));
    else
        L_y(1+(2*(s-1))) = (s1(s)+log(1+exp(s2(s)-s1(s))))-(s4(s)+log(1+exp(s3(s)-s4(s))));
    end
else
    if(s4(s)<s3(s))

        L_y(1+(2*(s-1))) = (s2(s)+log(1+exp(s1(s)-s2(s))))-(s3(s)+log(1+exp(s4(s)-s3(s))));
    else
        L_y(1+(2*(s-1))) = (s2(s)+log(1+exp(s1(s)-s2(s))))-(s4(s)+log(1+exp(s3(s)-s4(s))));
    end
end
  
if(s1(s)<s3(s))
    if(s2(s)<s4(s))
        L_y(2+(2*(s-1))) = (s3(s)+log((1+exp(s1(s)-s3(s)))))-(s4(s)+log(1+exp(s2(s)-s4(s))));
    else
        L_y(2+(2*(s-1))) = (s3(s)+log((1+exp(s1(s)-s3(s)))))-(s2(s)+log(1+exp(s4(s)-s2(s))));
    end
else
    if(s2(s)<s4(s))
        L_y(2+(2*(s-1))) = (s1(s)+log((1+exp(s3(s)-s1(s)))))-(s4(s)+log(1+exp(s2(s)-s4(s))));
    else
        L_y(2+(2*(s-1))) = (s1(s)+log((1+exp(s3(s)-s1(s)))))-(s2(s)+log(1+exp(s4(s)-s2(s))));
    end
end

%      L_y(1+(2*(s-1))) = (s1(s)+log(1+exp(s2(s)-s1(s))))/(s3(s)+log(1+exp(s4(s)-s3(s))));
%      L_y(2+(2*(s-1))) = (s3(s)+log(1+exp(s1(s)-s3(s))))/(s4(s)+log(1+exp(s2(s)-s4(s))));


% L_y(1+(4*(s-1))) = s1(s);
% L_y(2+(4*(s-1))) = s2(s);
% L_y(3+(4*(s-1))) = s3(s);
% L_y(4+(4*(s-1))) = s4(s);
end

llr_new = -L_y;

deinterleaver = deintrlv(llr_new,perm);

% soft demapping
% 
% %% Decoder
 [output, errors] = MpDecode(-deinterleaver, H_rows, H_cols, 50, 0, 1, 1, data );     % decoder

if (errors(50) > 0)
    Frame_errors = Frame_errors + 1;
end

if (Frame_errors == 100)
    break;
end

end
Frame_errors_SNR(l) = Frame_errors;
Frame_error_rate(l) = Frame_errors/iterations;
Frame_errors = 0;
waitbar(l/length(snr_dB));
end
close(h);
figure;
sem = semilogy(snr_dB,Frame_error_rate);
inter = linspace(0,50,50000);
pFER = interp1(snr_dB,Frame_error_rate,inter);
semilogy(inter,pFER);
snr_FER = find(pFER < 0.01);
snr_FER = snr_FER(1)/1000 + 0;
hold on;
grid on;
plot(snr_FER, 0.01, 'r*');
try
    snr_FER_001 = find(pFER < 0.001);
    snr_FER_001 = snr_FER_001(1)/1000 + 0;
    plot(snr_FER_001, 0.001, 'g*');
catch
    disp('No FER under 0.001');
end

% save('FER_1_2_QPSK_Fad.mat','Frame_error_rate');
% save('FER_plot_1_2_QPSK_Fad.fig','sem');
% save('snr_FER_1_2_QPSK_Fad.mat','snr_FER');

toc;