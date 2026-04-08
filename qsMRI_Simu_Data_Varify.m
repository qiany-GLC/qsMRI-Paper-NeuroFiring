% =====================================================================
% Simulation varification of qsMRI
% (C) Yongxian Qina, PhD
% 2026-02-08 (version 1.0)
% MATLAB R2021a - academic use
% =====================================================================
%

clearvars;

% set parameters
NS=1024; NCha=16; NScan=1; 
snr=250;            % |s(1)|/SD, at the 1st data sample
dts=0.0977e-3;      % in second, s
TEms=15; T2=50;     % in millisecond, ms
gammaBar = 42.58;   % MHz/T, for proton 1H

load ('fAP-PS.mat','fAP','fPS'); % fAP, fPS in uT  	% Get AP and PP waveforms

fAP2=[fAP;fAP]; fAP2(1:2:NS-1)=fAP/5; fAP2(2:2:NS)=fAP/5;   % Create AP channel, 
fPS2=[fPS;fPS]; fPS2(1:2:NS-1)=fPS/1; fPS2(2:2:NS)=fPS/1; 	% Create PP channel:

tms = TEms+((1:NS)'-1)*dts*1000;                            % Create time axis: 

% Check AP/PP channel 
figure('name','Firing Model: AP Channels')
plot(tms,fAP2);
xlabel('Time, ms'); ylabel('Magnetic field Bnz, uT')
grid on; grid minor

figure('name','Firing Model: PP Channels')
plot(tms,fPS2);
xlabel('Time, ms'); ylabel('Magnetic field Bnz, uT')
grid on; grid minor

 
% calculate phase = 2*pi*gammaBar*sum(B(t))*dt

phaAP =cumsum(fAP2);    % cumulative sum
phaPS =cumsum(fPS2);

expAP = exp(2i*pi*dts*phaAP*gammaBar);
expPS = exp(2i*pi*dts*phaPS*gammaBar);

% check expAP/PP phase 
figure('name','Firing Model: expAP phase')
plot(tms,angle(expAP));
xlabel('Time, ms'); ylabel('Simulated expAP w/o noise: Phase, a.u.')
grid on; grid minor
figure('name','Firing Model: expPS phase')
plot(tms,angle(expPS));
xlabel('Time, ms'); ylabel('Simulated expPS w/o noise: Phase, a.u.')
grid on; grid minor
 

% T2 decay
decay = exp(-tms/T2);

figure('name','Firing Model: T2 decay')
plot(tms,decay);
xlabel('Time, ms'); ylabel('Simulated T2 decay w/o noise: Real, a.u.')
grid on; grid minor


% complex random noise, independent from channel to channel
noiseReal = randn(NS,NCha,NScan);
noiseImag = randn(NS,NCha,NScan);    
noiseData =  noiseReal+ 1i*noiseImag;

figure('name','Firing Model: randn noise REAL')
plot(tms,real(noiseData(:,1:NCha)));
xlabel('Time, ms'); ylabel('Simulated random noise: Real, a.u.')
grid on; grid minor
figure('name','Firing Model: randn noise IMAGINARY')
plot(tms,imag(noiseData(:,1:NCha)));
xlabel('Time, ms'); ylabel('Simulated random noise : Imaginary, a.u.')
grid on; grid minor


% load amplitude from subject -H015v1
load('AmplRawData.mat')
figure('name','RawData Amplitude: amplRawData')
plot(AmplRawData);
xlabel('Cha #'); ylabel('Amplitude, a.u.')
grid on; grid minor


% create simulated fid signals
fidSimu = 0*noiseData;

for iCha=1:2:NCha
    fidSimu(:,iCha  ) = AmplRawData(iCha).* decay.* expPS;
    fidSimu(:,iCha+1) = AmplRawData(iCha).* decay.* expAP;
end

for iCha = 1:2      % 1-PP, 2-AP
figure('name','Firing Model: fidSimu no noise: Real')
plot(tms,real( fidSimu(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor
figure('name','Firing Model: fidSimu no noise: Imaginary')
plot(tms,imag( fidSimu(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor

figure('name','Firing Model: fidSimu no noise: Magnitude')
plot(tms,abs( fidSimu(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor
figure('name','Firing Model: fidSimu no noise: Phase')
plot(tms,angle( fidSimu(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor
end 


    % add random noise
fidSimuNoisy = fidSimu; 
for iCha=1:2:NCha
     
    fidSimuNoisy(:,iCha  ,1) = fidSimu(:,iCha  ,1) + (AmplRawData(iCha)/snr)*noiseData(:,iCha  ,1);
    fidSimuNoisy(:,iCha+1,1) = fidSimu(:,iCha+1,1) + (AmplRawData(iCha)/snr)*noiseData(:,iCha+1,1);
                   
end % of iCha

    % save the data just simulated
save('fidSimuData','fidSimu','fidSimuNoisy');   

for iCha = 1:2      % 1-PP, 2-AP
figure('name','Firing Model: fidSimu w/ noise: Real')
plot(tms,real( fidSimuNoisy(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor
figure('name','Firing Model: fidSimu w/ noise: Imaginary')
plot(tms,imag( fidSimuNoisy(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor

figure('name','Firing Model: fidSimu w/ noise: Magnitude')
plot(tms,abs( fidSimuNoisy(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor
figure('name','Firing Model: fidSimu w/ noise: Phase')
plot(tms,angle( fidSimuNoisy(:,iCha:iCha) ) );
xlabel('Time, ms'); ylabel('Simulated FID signal, a.u.')
grid on; grid minor
end 
