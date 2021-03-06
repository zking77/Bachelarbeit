%------------------------ Programme 3.1------------------------------------
%                  Simulation l'évanouissement du Rayleigh 
%                   pour différentes vitesses de MSi
%			 créer par B.Belgacem
%--------------------------------------------------------------------------
clear all;
close all;
clc;
rand('state',0);
%% Simulation parameters:
%--------------------------------------|-------------------------------|
%    Notation  &   value               |     Parameters                |
%--------------------------------------|-------------------------------|
K               = 03;%                 | number of users               | 
M               = 64;%                 | number of chip per symbol     |
B               = 2560/M;%             | number of symbol per slot     |
tram            = B*15*20;%            | numbre of trame               |
Rb              = (2560/M)/(10e-3/15);%| bit rate                      |
Rc              = Rb*M;               %| chip rate                     |  
v               = [5 30 100]          %|
%--------------------------------------|-------------------------------|
% generate a Rayleigh channel
[Ch_Rf_Des,Ch_Rf,Ch_Rf_a]= Gen_Channel(2,K,tram,B,M,v);
%-----------------------------------------------------------------------
%%                        Plot les résultats
%-----------------------------------------------------------------------
figure;
hold on
plot(10*log10(abs(Ch_Rf(2,:))),'-b');
ylabel('Amplitude (dB)','Interpreter','latex');
xlabel('temps $*16.66\mu s$','Interpreter','latex');
axis ([0 12001 -22 7])
grid;
%------------------------------------
hold off
figure;
hold on
plot(10*log10(abs(Ch_Rf(3,:))),'-b');
ylabel('Amplitude (dB)','Interpreter','latex');
xlabel('temps $*16.66\mu s$','Interpreter','latex');
axis ([0 12001 -22 7])
grid



