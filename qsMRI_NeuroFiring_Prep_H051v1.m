% qsMRI_NeuroFiring_Prep_H051v1 (Fig.5b: NeuroFiring)
% -------------------------------------------------------------------------
% Prepare verificaiton for human data: H051v1 64 FIDs at Tap, noTap, Rest
% (c) Yongxian Qian, Aoril 3, 2026 
% Version: 1.0 (2026-04-03, for Nature's reviewers)
% -------------------------------------------------------------------------
% param   -- structure to hold parameters and raw data for veriafication
% rawData -- a complex FID data to load up: 'fidSimuData'
%     dts -- sampling time interval, second (s)
%    TEms -- echo time, ms
%    TRms -- repetition time, ms 
% ----------------------------------------------------------------------
% 2026-04-02 yxq cleaned for Nature's reviewers
% 2026-04-07 yxq split a big data into two, then Concatenate _part1 and _part2
%
% -------------------------------------------------------------------------

clearvars;

    % define parameters
param.dts   = 0.2e-3;        % sec, sampling time interval in FID
param.TEms  = 0.2;           % ms, Echo time
param.TRms  = 1500;          % ms, Repetition time
param.myColor = '-k';        % color code for qsMRI plot: black
param.fidRange = [59,3,61];  % [stFid,increment,endFid] to plot

% === Tap ===
    % load raw FID data: H051v1 Head/Neck 20 channels 
    % [NCol,NCha,NScans]=[4096,20,64]
                                    
% load ('fidDataH051v1HN20_Tap','fidDataH051v1HN20_Tap'); 

load ('fidDataH051v1HN20_Tap_part1','fidDataH051v1HN20_Tap_part1');
load ('fidDataH051v1HN20_Tap_part2','fidDataH051v1HN20_Tap_part2');
fidDataH051v1HN20_Tap = cat(3, fidDataH051v1HN20_Tap_part1,fidDataH051v1HN20_Tap_part2);

param.fidData = fidDataH051v1HN20_Tap;   % FID raw data w/ complex valued data points
                                        % with 20 Head/Neck Channels
    % do qsMRI verification: Tap
qsMRI_NeuroFiring_Verify(param);

% === noTap ===
% load ('fidDataH051v1HN20_noTap','fidDataH051v1HN20_noTap');

load ('fidDataH051v1HN20_noTap_part1','fidDataH051v1HN20_noTap_part1');
load ('fidDataH051v1HN20_noTap_part2','fidDataH051v1HN20_noTap_part2');
fidDataH051v1HN20_noTap = cat(3, fidDataH051v1HN20_noTap_part1,fidDataH051v1HN20_noTap_part2);

param.fidData = fidDataH051v1HN20_noTap;

qsMRI_NeuroFiring_Verify(param);

% === Rest ===
% load ('fidDataH051v1HN20_Rest','fidDataH051v1HN20_Rest');

load ('fidDataH051v1HN20_Rest_part1','fidDataH051v1HN20_Rest_part1');
load ('fidDataH051v1HN20_Rest_part2','fidDataH051v1HN20_Rest_part2');
fidDataH051v1HN20_Rest = cat(3, fidDataH051v1HN20_Rest_part1,fidDataH051v1HN20_Rest_part2);

param.fidData = fidDataH051v1HN20_Rest;

qsMRI_NeuroFiring_Verify(param);

% end of prep



