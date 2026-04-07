function qsMRI_NeuroFiring_age_plot(param)
% -------------------------------------------------------------------------
% Plot verificaiton for human data: Healthy aging
% (c) Yongxian Qian, Aoril 3, 2026 
% Version: 1.0 (2026-04-03, for Nature's reviewers)
% -------------------------------------------------------------------------
% param   -- structure to hold parameters and raw data for veriafication
% nfrData -- neuronal firing rate
%    plID -- plot ID
%             'AgeRest' for whole brain resting with age
%             ''  
% ----------------------------------------------------------------------
% 2026-04-03 yxq cleaned for Nature's reviewers
%
% -------------------------------------------------------------------------

NFRatesAll  = param.nfrData;
plID        = param.plID;

szc = size (NFRatesAll);

NSubjs  = szc(1);           % nunber of subjects
NCha    = 20;               % number of coil channels
NTasks  = 3;                % number of tasks: {Tap, nonTap, Rest}
NComps  = 4;                % number of components 


% demography: {subjectID, sex, handed, age/year}
% NFRates1{1,1} = {'H057v1','M','R',62};

DemoInfo    = NFRatesAll(1:NSubjs,1);    % [subjID,sex,handed,age]
Task1Info   = NFRatesAll(1:NSubjs,2);    % tap   [mean, SD]
Task2Info   = NFRatesAll(1:NSubjs,3);    % notap [mean, SD]
Task3Info   = NFRatesAll(1:NSubjs,4);    % rest  [mean, SD]


    % initialize
age = 0*(1:NSubjs)';
sex = cell(length(age),1);

Task1MeanSD = zeros(NSubjs,NCha,2);
Task2MeanSD = zeros(NSubjs,NCha,2);
Task3MeanSD = zeros(NSubjs,NCha,2);


% ======================================
% get input data 
% ======================================

    % get demography: sex and age
for k=1:NSubjs    
    sex(k) = DemoInfo{k}(2);    % [subjID,sex,handed,age]
    age(k) = DemoInfo{k}{4};
end

ageMean = mean(age(:));
ageSD   = std(age(:));


    % get firing data: task1,task2,task3
for k=1:NSubjs
    
    clear temp1 temp2 temp3
        
    temp1 = Task1Info{k};           % Tap
    Task1MeanSD(k,:,:) = temp1;
    
    temp2 = Task2Info{k};           % noTap
    Task2MeanSD(k,:,:) = temp2;
    
    temp3 = Task3Info{k};           % Rest
    Task3MeanSD(k,:,:) = temp3;
end

    % get the mean values of firings
Task1mean   = Task1MeanSD(:,:,1);
Task2mean   = Task2MeanSD(:,:,1);
Task3mean   = Task3MeanSD(:,:,1);

    % get the SD values of firings
Task1SD   = Task1MeanSD(:,:,2);   
Task2SD   = Task2MeanSD(:,:,2);
Task3SD   = Task3MeanSD(:,:,2);


% ======================================
% Analyze data 
% ======================================

    % order age
[ageSort, ageI] = sort(age);

    % subgroup: sex
sexMale = (cell2mat(sex) == 'M');
sexFemale = (cell2mat(sex) == 'F');

ageMale = age(sexMale);         
[ageMSort, ageMI] = sort(ageMale);

ageFemale = age(sexFemale);     
[ageFSort, ageFI] = sort(ageFemale);


    % legend definition
sexOrder = ["M+F","Male","Female"];
taskOrder = ["Tap","noTap","Rest"];
changeOrder = ["Tap vs Rest","noTap vs Rest","Tap vs noTap"];


% ======================================
% Plot results 
% ======================================

switch plID 
    
    case 'AgeRest'
    % plot NF rate vs age at Resting state for whole brain
        
    % select channels for a region
    chaSelect =[3:16,19,20];    % head channels, excluding neck channels
    
    rateWholeBrainTsk3       = mean(Task3mean(:,chaSelect),2);
    rateWholeBrainTsk3SDmean = mean(Task3SD(:,chaSelect),2);
    
    figure('name','NeuroFiring in Whole Brain: Firing rate')
    
    hold on
    
plot(ageSort,rateWholeBrainTsk3(ageI),'-','Color','#0072BD','LineWidth',1.0);    

plot(age(sexMale),rateWholeBrainTsk3(sexMale),'s','MarkerSize',10,'Color','r','LineWidth',1.0);
errorbar(age(sexMale),rateWholeBrainTsk3(sexMale),rateWholeBrainTsk3SDmean(sexMale),'s','MarkerSize',10,'Color','r','LineWidth',1.0);

plot(age(sexFemale),rateWholeBrainTsk3(sexFemale),'o','MarkerSize',10,'Color','k','LineWidth',1.0);
errorbar(age(sexFemale),rateWholeBrainTsk3(sexFemale),rateWholeBrainTsk3SDmean(sexFemale),'o','MarkerSize',10,'Color','k','LineWidth',1.0);

    hold off
    
    xlabel('Age, year')
    ylabel('Firing rate, Hz')
    legend({'M+F','','Male','','Female'})
    box on
    grid on
    
    
    case 'AgeMotor'
    % plot NF rate vs age at 3 tasks (Tap,noTap,Rest) for the motor lobe
    
    chaSelect = [5,6,19,20];    % motor cortex2: [H23,H24,H21,H22]
                                %                [Cha5,Cha6,Cha19,Cha20]
    
    rateWholeBrainTsk1 = mean(Task1mean(:,chaSelect),2);
    rateWholeBrainTsk2 = mean(Task2mean(:,chaSelect),2);
    rateWholeBrainTsk3 = mean(Task3mean(:,chaSelect),2);

    rateWholeBrainTsk3SDmean = mean(Task3SD(:,chaSelect),2);
    rateWholeBrainTsk2SDmean = mean(Task2SD(:,chaSelect),2);
    rateWholeBrainTsk1SDmean = mean(Task1SD(:,chaSelect),2);
    
    % percent variation
    rateWholeBrainTsk1SDpct = 100*(rateWholeBrainTsk1SDmean./rateWholeBrainTsk1);
    rateWholeBrainTsk1SDpctMean = mean(rateWholeBrainTsk1SDpct(:)); 
    rateWholeBrainTsk1SDpctSD   = std(rateWholeBrainTsk1SDpct(:));  
    
    rateWholeBrainTsk2SDpct = 100*(rateWholeBrainTsk2SDmean./rateWholeBrainTsk2);
    rateWholeBrainTsk2SDpctMean = mean(rateWholeBrainTsk2SDpct(:)); 
    rateWholeBrainTsk2SDpctSD   = std(rateWholeBrainTsk2SDpct(:)); 
    
    rateWholeBrainTsk3SDpct = 100*(rateWholeBrainTsk3SDmean./rateWholeBrainTsk3);
    rateWholeBrainTsk3SDpctMean = mean(rateWholeBrainTsk3SDpct(:)); 
    rateWholeBrainTsk3SDpctSD   = std(rateWholeBrainTsk3SDpct(:));  
    
    % --- Firing rate
rateWholeBrainTskAll = [rateWholeBrainTsk1, rateWholeBrainTsk2, rateWholeBrainTsk3];

    figure('name','NeuroFiring in motor cortex: Firing rate')

    hold on

plot(ageSort,rateWholeBrainTskAll(ageI,1),'-o','Color','#0072BD','LineWidth',1.0);
plot(ageSort,rateWholeBrainTskAll(ageI,2),'--s','Color','[0.85 0.33 0.10]','LineWidth',1.0);
plot(ageSort,rateWholeBrainTskAll(ageI,3),'-+','Color','#EDB120','LineWidth',1.0);

    hold off

    xlabel('Age, year')
    ylabel('Firing rate, Hz')
    legend({'Tap','noTap','Rest'})
    box on
    grid on
    
    % ========================================================
    %  Relative change in rate, percent
    % ========================================================

rateWholeBrainTskAllChange13 = 100*(rateWholeBrainTsk1 ./ rateWholeBrainTsk3 -1);
rateWholeBrainTskAllChange23 = 100*(rateWholeBrainTsk2 ./ rateWholeBrainTsk3 -1);
rateWholeBrainTskAllChange12 = 100*(rateWholeBrainTsk1 ./ rateWholeBrainTsk2 -1);

rateWholeBrainTskAllChange = [rateWholeBrainTskAllChange13, rateWholeBrainTskAllChange23, rateWholeBrainTskAllChange12];


    figure('name','NeuroFiring in Motor cortex: Change')
    
    hold on
    
    plot(ageSort,rateWholeBrainTskAllChange(ageI,1),'-o','Color','#0072BD','LineWidth',1.0);
    plot(ageSort,rateWholeBrainTskAllChange(ageI,2),'--s','Color','[0.85 0.33 0.10]','LineWidth',1.0);
    plot(ageSort,rateWholeBrainTskAllChange(ageI,3),'-+','Color','#EDB120','LineWidth',1.0);

    yline(0,'-k','LineWidth',1.0);
    hold off

    ylim([-100,300]);
    xlabel('Age, year')
    ylabel('Relative change in firing rate, %')
    legend({'Tap vs. Rest','noTap vs. Rest','Tap vs. noTap'});
    box on
    grid on

    
    otherwise
    
end

end