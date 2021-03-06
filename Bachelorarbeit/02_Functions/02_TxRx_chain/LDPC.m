%% Tx/Rx-Chain (Encoder/Decoder and Mapping/Demapping) for QPSK
%  Small script intended to get first look into the CM -Library and using
%  given functions. LDPC encoding was used here. 
%  Used functions:
%  - [H_rows, H_cols, P] = InitializeWiMaxLDPC( rate, number_of_symbols)
%  - LdpcEncode( data, H_rows, P)
%  - CreateConstellation( 'modulation_scheme', M);
%  - Modulate( codeword, Modulation_scheme)
%  - Demod2D( received_symbols, modulation_Scheme, EsNo)
%  - SoMap(loglikelihood)
%  - [output, errors] = MpDecode(-llr, H_rows, H_cols, iter, 0, 1, 1, data)
%
%  After restarting MATLAB CmlStartup has to be run once from the cml
%  folder!

%% Initialization
%addpath('Bachelorarbeit/cml/');
%CmlStartup;

n = 2304;                                                                   % 576:96:2304
rate = 1/2;                                                                % R = k/n
<<<<<<< HEAD
snr_dB = 10;
=======
snr_dB = 20;
>>>>>>> 2c99282b070b8a7eeefefa9d7199ec1f665ff54e
cnt = 1;
%% Encoder
[H_rows, H_cols, P] = InitializeWiMaxLDPC(rate, n);                        % creating H-Matrix r x n

k = length( H_cols) - length(P);

data = round(rand(1,k));

codeword = LdpcEncode(data, H_rows, P);                                    % codewords c

%% Mapping
QPSK = CreateConstellation( 'QPSK');                                       % QAM, PSK, FSK, etc. possible

symbols = Modulate(codeword,QPSK);

% channel

EsNo = 10^(snr_dB/10);

amplitude = sqrt(EsNo);

variance = 1/(2*EsNo);

noise = sqrt(1/2)*(randn(size(symbols))+1i*randn(size(symbols))); 

r = amplitude*symbols + noise;

%% Demapping
% sym_ll = Demod2D(r, QPSK, EsNo);                                           % transforms received symbols into log-likelihoods
% 
% llr = Somap(sym_ll);                                                       % soft demapping
x = amplitude*[1 j -j -1];
for s = 1:n/2
s1(s) = -(abs(r(s)-x(1)).^2);    %1
s2(s) = -(abs(r(s)-x(2)).^2);    
s3(s) = -(abs(r(s)-x(3)).^2);
s4(s) = -(abs(r(s)-x(4)).^2);

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

%% Decoder
[output, errors] = MpDecode(-llr_new, H_rows, H_cols, 50, 0, 1, 1, data );     % decoder
