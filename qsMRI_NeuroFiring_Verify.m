function qsMRI_NeuroFiring_Verify (param)
% -------------------------------------------------------------------------
% Calculate neuronal firing magnetic field and firing rate
% (c) Yongxian Qian, November 14, 2020 
% Version: 1.0 (2026-03-30, for Nature's reviewers)
% -------------------------------------------------------------------
% param    -- parameter data for inputs
% rawData  -- a complex FID data to load up: 'fidSimuData'
% parmData -- parameters, to calculate firings
%       dt -- sampling time interval, ms
%   algId  -- algorithm ID, fixed to 'phase'
% outMagneticField -- micro Tesla, output magnetic field of firing 
% -----------------------------------------------------------
% 2026-03-30 yxq cleaned for Nature's reviewers
%
% -----------------------------------------------------------

% clearvars;

    % get parameters
dts     = param.dts;                 % sec, sampling time interval in FID
TEms    = param.TEms;                % ms, Echo time
TRms    = param.TRms;                % ms, Repetition time
myColor = param.myColor;             % color code for qsMRI plot

rawData = param.fidData;            % FID raw data w/ complex valued data points

sz_rawData = size(rawData);         % find dimensions

NCol = sz_rawData(1);               % number of data points in colum
NCha = sz_rawData(2);               % number of channels

NScans = 1;                          % numner of scans (TRs or FIDs)
if length (sz_rawData) > 2
    NScans = sz_rawData(3);
end

    
    % calculate firing-associated magnetic field using PHASE algorithm
iFreq = lnfPhase(rawData,dts);  % Hz, frequency

gamma = 42.58;                      % MHz/T, proton 1H
iMagnet = iFreq ./ gamma ;          % scale to micro Telsa, uT


    % plot neuronal firings
    
    % local time in one Readout
tms = TEms + (0:NCol-1)'*dts*1000;  % dts in sec, TEms in ms

    % global (long) time in entire acquisition: connect time segments to iMagnet
sztL = length(tms);
tLong = zeros(NScans*sztL,1);  
for iScan=1:NScans
    tLong((iScan-1)*sztL+(1:sztL)) = (iScan-1)*TRms + tms;
end

    % global (long) data chain
szLNFLong   = [NCol*NScans,NCha];
iMagnetLong = reshape(permute(iMagnet,[1,3,2]),szLNFLong);


ifScale = 0.5;      % scale 2xuT
nFid = 3;           % number of FIDs to dispaly per an epoch

stFid = 1; 
endFid = NScans;
% endFid = min(NScans-nFid, NScans);

if isfield(param, 'fidRange')
    fidRange = param.fidRange;
    stFid   = fidRange(1);
    nFid    = fidRange(2);
    endFid  = fidRange(3);   
end

for iFid = stFid:nFid:endFid
    
    ddFid = endFid - iFid + 1;          % remaining FIDs
    if ( ddFid < nFid), nFid=ddFid; end
      
    NFPlot(iMagnetLong,tLong,NCol,iFid,nFid,ifScale,myColor)    
end

end % of function
% ==========================


function iFreq = lnfPhase(rawData,dt)

        % Dph = ph(t) - ph(t-dt); backward difference
    dPhaseBW = angle(rawData(:,:,:).*conj(rawData([1,1:end-1],:,:)));
        % Dph = ph(t+dt) - ph(t); forward difference
    dPhaseFW = angle(conj(rawData(:,:,:)).*rawData([2:end,end],:,:));
        
        % freq = phase/2pi/dt; average over backward and forward
    iFreq = (dPhaseFW + dPhaseBW)/(4*pi*dt);
%     ifreq = (dPhaseFW + 0)/(2*pi*dt);
        
        % zero the two ends
    iFreq([1,end],:,:) = 0;
        
        % 3-point smoothing
    iFreq(2:end-1,:,:)=(1/3)*(iFreq(2:end-1,:,:)+iFreq(3:end,:,:)+iFreq(1:end-2,:,:));
    iFreq([1,end],:,:) = 0;
    
end

function NFPlot(data,tGlobal,NS,iFid,nFid,ifScale,myColor)
% -----------------------------------------------------------
% Plot neuronal firing waveforms
% (c) Yongxian Qian, November 14, 2020 
% Version: 1.0 (11-14-2020)
% -----------------------------------------------------------
%    Data -- real data NCol x NCha
% tGlobal -- ms, global time NS x 1
%      NS -- Number of samples in local FID
%    iFid -- FID index to display
%    nFid -- number of FIDs to display in a row
% ifScale -- Bnz line scale, i.e., 0.1 (x10 uT)
% -----------------------------------------------------------
% 2026-03-30 yxq cleaned for Nature's reviewers
%
% -----------------------------------------------------------

exLDF   = 20; %2;        % inter-line shift of uT

NCha    = size(data,2);     % number of channels


% index range to display
cutDisp = (1:nFid*NS)+(iFid-1)*NS;


% time scale
tt = tGlobal(cutDisp);      % axis for time
DTT = tt(9)-tt(8);          % interval in time, ms


% display

figure('name',['mrNeuroFiring Bnz iFID=' int2str(iFid)])

hold on

for iCha=1:NCha

    yy = -exLDF*(iCha-1)+ifScale*data(cutDisp,iCha);
    
%     pCha = plot(tt,yy,'-k');
    pCha = plot(tt,yy,myColor);
    
    txt = ['Ch' int2str(iCha)];
    text(tt(end)+DTT,yy(end),txt,'Color',pCha.Color);
    
end

hold off
xlabel('Time, ms')
ylabel(['Magnetic field Bnz, x ' num2str(1/ifScale) ' uT'])
grid on
grid minor
box on

end