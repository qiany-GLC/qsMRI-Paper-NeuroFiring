
function qsMRI_NeuroFiring_prep_plot(param,plType)
% -------------------------------------------------------------------------
% plot raw fid data
% (c) Yongxian Qian, Aoril 1, 2026 
% Version: 1.0 (2026-04-01, for Nature's reviewers)
% -------------------------------------------------------------------------
% param   -- structure to hold parameters and fid data
% plType  -- plot data type: 'Magnitude','Phase', or 'UnwrappedPhase' 
% -----------------------------------------------------------
% 2026-04-01 yxq cleaned for Nature's reviewers
%
% -------------------------------------------------------------------------
    
fidData = param.fidData;
NCol = size(fidData,1);
NCha = size(fidData,2);
    
tms = param.TEms + param.dts*1000*(0:NCol-1)';
    
figure ('name',['fidData: ', plType,' Scan-' num2str(1)])
    
switch plType
    case 'Magnitude'
        for iCha = 1:NCha
        plot(tms, abs(fidData(:,iCha,1)),param.myColor,'DisplayName',sprintf('Ch%d',iCha))
        hold on;
        end
        ylabel('FID: Magnitude, a.u.')
        
    case 'Phase'
        for iCha = 1:NCha
        plot(tms, angle(fidData(:,iCha,1)),param.myColor,'DisplayName',sprintf('Ch%d',iCha))
        hold on;
        end
        ylabel('FID: Phase, rad')
        
    case 'UnwrappedPhase'
        for iCha = 1:NCha
        plot(tms, unwrap(angle(fidData(:,iCha,1)) ),param.myColor,'DisplayName',sprintf('Ch%d',iCha))
        hold on;
        end
        ylabel('FID: Phase unwrapped, rad')
    otherwise
        
end
    
xlabel('Readout time, ms')
legend('show')
grid on
box on

end
