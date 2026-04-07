% qsMRI_NeuroFiring_Prep_Simulation
% -------------------------------------------------------------------------
% Prepare verificaiton for Simulation
% (c) Yongxian Qian, March 30, 2026 
% Version: 1.0 (2026-03-30, for Nature's reviewers)
% -------------------------------------------------------------------
% param   -- structure to hold parameters and raw data for veriafication
% rawData -- a complex FID data to load up: 'fidSimuData'
%     dts -- sampling time interval, second (s)
%    TEms -- echo time, ms
%    TRms -- repetition time, ms 
% -----------------------------------------------------------
% 2026-03-31 yxq cleaned for Nature's reviewers
%
% -----------------------------------------------------------

clearvars;

    % define parameters
param.dts   = 0.0977e-3;        % sec, sampling time interval in FID
param.TEms  = 15;               % ms, Echo time
param.TRms  = 800;             % ms, Repetition time
param.myColor = '-';            % color code for qsMRI plot

load ('fidSimuData');           % load simu/raw FID data

param.fidData = fidSimuNoisy;   % noisy FID raw data w/ complex valued data points
% param.fidData = fidSimu;      % clean FID raw data


    % do qsMRI verification
qsMRI_NeuroFiring_Verify(param);

% end of prep



