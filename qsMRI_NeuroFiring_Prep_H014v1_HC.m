% qsMRI_NeuroFiring_Prep_H014v1_HC (Fig.6b,f,g: NeuroFiring)
% -------------------------------------------------------------------------
% Prepare verificaiton for human data: H014v1 (matched Healthy Control), 64 FIDs at Rest
% (c) Yongxian Qian, April 7, 2026 
% Version: 1.0 (2026-04-07, for Nature's reviewers)
% -------------------------------------------------------------------------
% param   -- structure to hold parameters and raw data for veriafication
% rawData -- a complex FID data to load up: 'fidSimuData'
%     dts -- sampling time interval, second (s)
%    TEms -- echo time, ms
%    TRms -- repetition time, ms 
% ----------------------------------------------------------------------
% 2026-04-07 yxq cleaned for Nature's reviewers
%
% -------------------------------------------------------------------------

clearvars;

    % define parameters
param.dts   = 0.2e-3;        % sec, sampling time interval in FID
param.TEms  = 0.2;           % ms, Echo time
param.TRms  = 1500;          % ms, Repetition time
param.myColor = '-k';        % color code for qsMRI plot: black
param.fidRange = [7,17];     % [iFID#,iFID#] to plot

param.epochMs      = 300;    % ms, time period at each TR to count firing pulses
param.epochAmpl    = 1;    % uT, threshold for eligible firing peaks


% === Rest ===

 % load the modified raw FID data: H014v1Mod Head/Neck 20 channels 
    % [NCol,NCha,NScans]=[4096,20,64]: already set ZEROs at Neck channels [13,14,17,18]
load ('fidDataH014v1HN20Mod_Rest','fidDataH014v1HN20Mod_Rest');  

param.fidData = fidDataH014v1HN20Mod_Rest;   % FID raw data w/ complex valued data points
                                        % with 20 Head/Neck Channels

qsMRI_NeuroFiring_Verify_EP(param);

% end of prep