function [nfFRate,nfRateMean,nfRateSD] = getNFRate(nfDataUT,epochAmpl,epochMs,dtms,TRms)
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
    
    txt = ['Cha' int2str(iCha)];
    text( (tTRms(end)+5*dtms)*0.001,iShift,txt,'Color',pCha.Color);
    
end

hold off

xlabel('Time, sec')
ylabel('Mean-centered firing rate, Hz')

ax = gca;
ax.XLim = ax.XLim - [0.1,0];    %left-shift y-axis
box on


    % display bar plot of mean+/-SD
figure('name',['NeuroFiring mean+/-SD @ [NCha,NScans] = ' '[' int2str(NCha),', ',int2str(NScans),']'])

bar(nfRateMean);

hold on

er1 = errorbar(nfRateMean,nfRateSD);    
er1.Color = [0 0 0];                            
er1.LineStyle = 'none';  

hold off

xlabel('Channel #')
ylabel('Firing rate, Hz')
box on

end

