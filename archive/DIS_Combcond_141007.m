function DIS_Combcond_141007(subjID)

cd /younglab/studies/DIS_MVPA/behavioural/controlConditionRegressor

names = dir([subjID '*']);

cd /younglab/studies/DIS_MVPA/behavioural/controlConditionRegressor

% Even though in the analyses, people are interested in looking at the
% onsets of the different parts of a trial, the onsets aren't jittered like
% they were in XPECT, so that you can actually just look at the outputs
% and break it down by timecourse. You'll only want one call for behavioral
% files, and it should call everything. Also! This set of behavioral files
% won't have any new contrasts, because all of the old behavioral files
% have all the contrasts I think we need.
files = dir([subjID '.DIS.*'])
for file=1:length(files)
    if file ~= 1
       cd /younglab/studies/DIS_MVPA/behavioural/controlConditionRegressor
    end
        
    load(files(file).name);

%     xx(1).name = 'A_HARM';
%     xx(1).ons = sort([spm_inputs(1).ons, spm_inputs(2).ons, spm_inputs(6).ons, spm_inputs(7).ons]);
%     xx(1).dur = sort([spm_inputs(1).dur; spm_inputs(2).dur; spm_inputs(6).dur; spm_inputs(7).dur]);
%     xx(2).name = 'B_PURITY';
%     xx(2).ons = sort([spm_inputs(3).ons, spm_inputs(4).ons, spm_inputs(8).ons, spm_inputs(9).ons ]);
%     xx(2).dur = sort([spm_inputs(3).dur; spm_inputs(4).dur; spm_inputs(8).dur; spm_inputs(9).dur]);
%  
%    spm_inputs = xx;
%    clear xx
%         
        clear con_info
        % Main Comparisons across all categories
        con_info(1).name = 'Harm_vs_Purity';

        con_info(1).vals = [1 -1];

        con_info(2).name = 'Purity_vs_Harm';

        con_info(2).vals = [-1 1];

    
cd /younglab/studies/DIS_MVPA/behavioural/controlConditionRegressor
    save([subjID '.DIS.domain' num2str(acq) '.mat' ],'acq','RT','key','design','design_run','items','items_run','ips', 'con_info', 'spm_inputs', 'experimentDur', 'subjID', 'user_regressors');
    clear acq RT key design design_run item items_run ips con_info spm_inputs experimentDur xx;

end
% % now, do both domain and intent
cd /younglab/studies/DIS_MVPA/behavioural/141007_redoneDomint

files = dir([subjID '.DIS.*'])
for file=1:length(files)
    if file ~= 1
       cd /younglab/studies/DIS_MVPA/behavioural/141007_redoneDomint
    end
        
    load(files(file).name);
% 
%     yy(1).name = 'A_ACCH';
%     yy(1).ons = sort([spm_inputs(1).ons, spm_inputs(2).ons]);
%     yy(1).dur = sort([spm_inputs(1).dur; spm_inputs(2).dur]);
%     yy(2).name = 'B_ACCP';
%     yy(2).ons = sort([spm_inputs(3).ons, spm_inputs(4).ons]);
%     yy(2).dur = sort([spm_inputs(3).dur; spm_inputs(4).dur]);
%     yy(3).name = 'C_INTH';
%     yy(3).ons = sort([spm_inputs(6).ons, spm_inputs(7).ons]);
%     yy(3).dur = sort([spm_inputs(6).dur; spm_inputs(7).dur]);
%     yy(4).name = 'D_INTP';
%     yy(4).ons = sort([spm_inputs(8).ons, spm_inputs(9).ons]);
%     yy(4).dur = sort([spm_inputs(8).dur; spm_inputs(9).dur]);
%     
%     spm_inputs = yy;
%     clear yy
% 
        clear con_info
        % Main Comparisons across all categories
        con_info(1).name = 'Harm_vs_Purity';

        con_info(1).vals = [1 -1];

        con_info(2).name = 'Purity_vs_Harm';

        con_info(2).vals = [-1 1];
cd /younglab/studies/DIS_MVPA/behavioural/141007_redoneDomint
    save([subjID '.DIS.domint.redone' num2str(acq) '.mat' ],'acq','RT','key','design','design_run','items','items_run','ips', 'con_info', 'spm_inputs', 'experimentDur', 'subjID');
    clear acq RT key design design_run item items_run ips con_info spm_inputs experimentDur xx;

end

cd /younglab/studies/DIS_MVPA/behavioural/141007_redoneDomint


end
