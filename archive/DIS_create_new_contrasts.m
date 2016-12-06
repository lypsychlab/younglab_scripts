% cd /younglab/studies/DIS/behavioural/DomainControlreg
% all_dir = dir('SAX_DIS_*');
% for i=1:length(all_dir)
%     all_dir = dir('SAX_DIS_*');
%     load(all_dir(i).name);
    
%     con_info = con_info(1);
    
%     %correct for previous mistake labeling
%     con_info(5).name = 'all accidental vs all intentional';
%     con_info(6).name = 'all intentional vs all accidental';
%     
%     %create new contrasts 
%     con_info(30).name = 'intentional psych harm vs intentional phys harm';
%     con_info(30).vals = [0 0 0 0 0 -1 1 0 0 0];
%     con_info(31).name = 'intentional phys harm vs intentional psych harm';
%     con_info(31).vals = [0 0 0 0 0 1 -1 0 0 0];
%     con_info(32).name = 'intentional psych harm vs accidental psych harm';
%     con_info(32).vals = [0 -1 0 0 0 0 1 0 0 0];
%     con_info(33).name = 'accidental psych harm vs intentional psych harm';
%     con_info(33).vals = [0 1 0 0 0 0 -1 0 0 0];
%     con_info(34).name = 'intentional phys harm vs accidental phys harm';
%     con_info(34).vals = [-1 0 0 0 0 1 0 0 0 0];
%     con_info(35).name = 'accidental phys harm vs intentional phys harm';
%     con_info(35).vals = [1 0 0 0 0 -1 0 0 0 0];
%     con_info(36).name = 'accidental psych harm vs accidental phys harm';
%     con_info(36).vals = [-1 1 0 0 0 0 0 0 0 0];
%     con_info(37).name = 'accidental phys harm vs accidental psych harm';
%     con_info(37).vals = [1 -1 0 0 0 0 0 0 0 0];
%     con_info(38).name = 'incest vs psych harm';
%     con_info(38).vals = [0 -1 1 0 0 0 -1 1 0 0];
%     
%     con_info = con_info(1:38);
%    
%     con_info = con_info(1)
%     con_info(1).name='harm vs purity'
%     con_info(1).vals=[1 -1]
%     con_info(2).name='purity vs harm'
%     con_info(2).vals=[-1 1]
%     
% 
%     cd /younglab/studies/DIS/behavioural/Domain;
%     save(all_dir(i).name,'con_info','-append');
%     
%     
% end

% %% add Domint contrasts
% 
% cd /younglab/studies/DIS_MVPA/behavioural/DomintControlreg
% all_dir = dir('SAX_DIS_*');
% for i=1:length(all_dir)
%     all_dir = dir('SAX_DIS_*');
%     load(all_dir(i).name);
%     
%     con_info = con_info(1)
%     
%     con_info(1).name='accidental harm vs intentional harm'
%     con_info(1).vals=[1 0 -1 0 0]
%     con_info(2).name='accidental purity vs intentional purity'
%     con_info(2).vals=[0 1 0 -1 0]
%     con_info(3).name='intentional harm vs accidental harm'
%     con_info(3).vals=[-1 0 1 0 0]
%     con_info(4).name='intentional purity vs accidental purity'
%     con_info(4).vals=[0 -1 0 1 0]
%     con_info(5).name='accidental vs intentional'
%     con_info(5).vals=[1 1 -1 -1 0]
%     con_info(6).name='intentional vs accidental'
%     con_info(6).vals=[-1 -1 1 1 0]
%     
%     cd /younglab/studies/DIS_MVPA/behavioural/DomintControlreg;
%     save(all_dir(i).name,'con_info', '-append');
% end


%% add Domain contrasts

cd /younglab/studies/DIS_MVPA/behavioural/DomainControlreg
all_dir = dir('SAX_DIS_*');
for i=1:length(all_dir)
    all_dir = dir('SAX_DIS_*');
    load(all_dir(i).name);
    
    con_info = con_info(1)
    
        con_info(1).name = 'Harm_vs_Purity';

        con_info(1).vals = [1 -1 0];

        con_info(2).name = 'Purity_vs_Harm';

        con_info(2).vals = [-1 1 0];
    
    cd /younglab/studies/DIS_MVPA/behavioural/DomainControlreg;
    save(all_dir(i).name,'con_info', '-append');


% %create nuisance regressor for control condition 
%         
% cd /younglab/studies/DIS_MVPA/behavioural/controlConditionRegressor
% all_dir = dir('SAX_DIS_*');
% cd /younglab/studies/DIS_MVPA/behavioural/DomainControlreg
% all_dir2 = dir('SAX_DIS_*');
% for i=1:length(all_dir)
%     cd /younglab/studies/DIS_MVPA/behavioural/controlConditionRegressor
%     all_dir = dir('SAX_DIS_*');
%    
%     load(all_dir(i).name);
%     clearvars -except user_regressors all_dir all_dir2
%     
%     cd /younglab/studies/DIS_MVPA/behavioural/DomainControlreg
%     all_dir2 = dir('SAX_DIS_*');
%     load(all_dir2(i).name);
%     
% %     user_regressors(1).name = 'control';
% %     user_regressors(1).ons = sort([spm_inputs(5).ons, spm_inputs(10).ons]);
%     
%     cd /younglab/studies/DIS_MVPA/behavioural/DomainControlreg;
%     save(all_dir(i).name,'user_regressors', '-append');
%     
end