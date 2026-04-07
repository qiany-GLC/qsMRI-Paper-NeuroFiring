% qsMRI_NeuroFiring_Prep_Bottle
% -------------------------------------------------------------------------
% Prepare verificaiton for Phantom data: Bottle
% (c) Yongxian Qian, Aoril 1, 2026 
% Version: 1.0 (2026-04-01, for Nature's reviewers)
% -------------------------------------------------------------------------
% param   -- structure to hold parameters and raw data for veriafication
% rawData -- a complex FID data to load up: 'fidSimuData'
%     dts -- sampling time interval, second (s)
%    TEms -- echo time, ms
%    TRms -- repetition time, ms 
% ----------------------------------------------------------------------
% 2026-03-31 yxq cleaned for Nature's reviewers
%
% -------------------------------------------------------------------------

clearvars;

    % define parameters
param.dts   = 0.0977e-3;        % sec, sampling time interval in FID
param.TEms  = 15;               % ms, Echo time
param.TRms  = 800;             % ms, Repetition time
param.myColor = '-';            % color code for qsMRI plot

load ('fidDataBottle16','fidDataBottle2');        % load raw FID data: Bottle phantom 
                                    % [NCol,NCha,NScans]=[1024,16,1]

param.fidData = fidDataBottle2;   % FID raw data w/ complex valued data points
                                    % with 16 Head Channels
    % plot magnitude
qsMRI_NeuroFiring_prep_plot(param,'Magnitude');

    % plot phase
qsMRI_NeuroFiring_prep_plot(param,'Phase');

    % plot unwrapped phase
qsMRI_NeuroFiring_prep_plot(param,'UnwrappedPhase');
                                    
    % do qsMRI verification
qsMRI_NeuroFiring_Verify(param);

% end of prep



