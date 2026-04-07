function qsMRI_NeuroFiring_Verify_EP (param)
% -------------------------------------------------------------------------
% Calculate neuronal firing magnetic field and firing rate
% (c) Yongxian Qian, November 14, 2020 
% Version: 1.0 (2026-04-06, for Nature's reviewers)
% -------------------------------------------------------------------
% param    -- parameter data for inputs
% rawData  -- a complex FID data to load up: 'fidSimuData'
% parmData -- parameters, to calculate firings
%      dts -- sampling time interval, in second (s)
%   algId  -- algorithm ID, fixed to 'phase'
% -----------------------------------------------------------
% 2026-04-06 yxq cleaned for Nature's reviewers
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

    % down-sampling raw data by 2x and update parameters associated
rawData = (rawData(1:2:NCol-1,:,:) + rawData(2:2:NCol,:,:)) / 2;
NCol    = NCol/2;
dts     = dts*2;

    
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
nFid = 1;           % number of FIDs to dispaly per an epoch

stFid = 1; 
endFid = NScans;

fidSelect    = param.fidRange;      % selected FIDs to plot
lenFidSelect = length(fidSelect);


for ii = 1:lenFidSelect
    iFid = fidSelect(ii); 
    
    ddFid = endFid - iFid + 1;          % remaining FIDs
    if ( ddFid < nFid), nFid=ddFid; end
      
    NFPlot(iMagnetLong,tLong,NCol,iFid,nFid,ifScale,myColor)    
end


    % calculate firing rate = peaks per second
epochMs      = param.epochMs;   % ms, time period at each TR to count firing peaks
epochAmpl    = param.epochAmpl; % uT, threshold for eligible firing peaks
    
getNFRate_Verify(iMagnet,epochAmpl,epochMs,dts*1000,TRms);


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
tt = tGlobal(cutDisp) * 1e-3;      % axis for time
DTT = (tt(9)-tt(8)) * 1e-3;          % interval in time, ms


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
xlabel('Time, s')
ylabel(['Magnetic field Bnz, x ' num2str(1/ifScale) ' uT'])
grid on
grid minor
box on

end

function getNFRate_Verify(nfDataUT,epochAmpl,epochMs,dtms,TRms)
% -------------------------------------------------------------------------
% Detect peaks and calculate firing rate
% (c) Yongxian Qian, November 14, 2020 
% Version: 1.0 (2026-04-06, for Nature's reviewers)
% -------------------------------------------------------------------
% param    -- parameter data for inputs
% nfDataUT -- Data of neuronal firing (magentic field) in uT
%     TRms -- TR in ms
% -----------------------------------------------------------
% 2026-04-06 yxq cleaned for Nature's reviewers
%
% -----------------------------------------------------------

% clearvars;

sz = size(nfDataUT);

NCol = sz(1);
NCha = sz(2);

NScans = 1;
if length(sz) > 2
    NScans = sz(3);
end

    % compute numner of samples with window NT
NT = int32(epochMs/dtms);


    % thresholding small peaks
nfDataUTMag = abs(nfDataUT);                    % take magnitude
nfDataUTMag(nfDataUTMag < epochAmpl) = 0;       % thresholding
nfDataUTMag(NT+1:end,:,:) = 0;                  % cut-off tail


    % detect peaks
nfPeaks = 0*nfDataUTMag;        % initialize peak lable: 0-no, 1-yes

for jScan=1:NScans
    for jCha=1:NCha
        for jSample=2:NT-1
            
            a1 = nfDataUTMag(jSample-1, jCha,jScan);
            a2 = nfDataUTMag(jSample  , jCha,jScan);
            a3 = nfDataUTMag(jSample+1, jCha,jScan);
            
            if 2*a2 > a1+a3
                nfPeaks(jSample,jCha,jScan) = 1;
            end
            
        end
    end
end


    % calculate rate, MEAN, and SD
nfFRate = squeeze(sum(nfPeaks,1))./(0.001*epochMs);     % Hz, peaks/s, [NCha,NScans]

nfRateMean  = squeeze(mean(nfFRate,2));   % Hz, [NCha], mean along scans

    % S = std(A,w,dim), w=0 if 1/(N-1)
nfRateSD    = squeeze(std(nfFRate,0,2));    % Hz, [NCha], SD along scans, 


% display nfr dynamics along TR
%
figure('name','Firing rate dynamics along TR')

hold on

tTRms0 = epochMs/2;                           % center time of 1st epoch
tTRms = ( tTRms0 + TRms*(0:(NScans-1) ) )';   % center time of each TR/epoch

yNfrShift = 1.0* max(nfRateSD(:));            % distance between channels


for iCha=1:NCha

    iShift = (iCha-1) * yNfrShift;                          % set center line
    
    yNFR = nfFRate(iCha,:) - nfRateMean(iCha) + iShift;      % centered at MEAN and shifted to center line 
        
    plot([tTRms(1),tTRms(end)]*0.001,[iShift,iShift],'-k');     % draw center line
    pCha = plot(tTRms*0.001,yNFR,'-');
    
    txt = ['Ch' int2str(iCha)];
    text( (tTRms(end)+5*dtms)*0.001,iShift,txt,'Color',pCha.Color);
    
end

hold off

xlabel('Time, sec')
ylabel('Mean-centered firing rate, Hz')

ax = gca;
ax.XLim = ax.XLim - [0.1,0];    %left-shift y-axis
box on
ax.XGrid = 'on';


    % display bar plot of mean+/-SD
figure('name',['NeuroFiring mean+/-SD @ [NCha,NScans] = ' '[' int2str(NCha),', ',int2str(NScans),']'])

bar(nfRateMean);

hold on

er1 = errorbar(nfRateMean,nfRateSD);    
er1.Color = [0 0 0];                            
er1.LineStyle = 'none';  

hold off

ax = gca;
xlabel('Channel #')
ylabel('Firing rate, Hz')
ax.YGrid      = 'on';
ax.GridAlpha  = 0.25;
ax.GridLineStyle = '-';
ax.YMinorGrid = 'on';
box on

end
