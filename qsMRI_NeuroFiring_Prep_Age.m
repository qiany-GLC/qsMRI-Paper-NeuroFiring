% qsMRI_NeuroFiring_Prep_Age
% -------------------------------------------------------------------------
% Prepare verificaiton for human data (25 healthy subjects): age, rest, whole brain
% (c) Yongxian Qian, Aoril 3, 2026 
% Version: 1.0 (2026-04-03, for Nature's reviewers)
% -------------------------------------------------------------------------
% param   -- structure to hold parameters and raw data for veriafication
% nfrData -- neuronal firing data
% ----------------------------------------------------------------------
% 2026-04-03 yxq cleaned for Nature's reviewers
%
% -------------------------------------------------------------------------

clearvars;

    % load neuronal firing rate data:{demoInfo,Tap,nonTap,Rest}
    % healthy subjects: 25
load ('NeuroFiringRates_Ages_25HC','NFRatesAll');  
                                     
                                    
param.nfrData = NFRatesAll;   % all age NeuroFiring rate data
param.plID = 'AgeRest';       % 'AgeRest' for age at Resting and whole brain
                               

    % plot firing rate with age: mean +/- SD
qsMRI_NeuroFiring_age_plot(param);

% end of prep

