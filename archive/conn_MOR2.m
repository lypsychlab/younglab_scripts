clear all;

tic;
study='MOR2';
subj_nums=[9 10 14 15 22 23 24]; 
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['KAN_MOR2_' sprintf('%02d',s) '_dcm'];
    
end

for s=1:length(subjs)
%     cd(fullfile('/younglab/studies/MOR2/',subjs{s},'results/fb_results'));
%     load('SPM.mat');
%     sessions{s}=SPM.xY.P;
%     clear SPM;
    if ismember(subj_nums(s),[9 10 14 24])
        sessions{s}=[3 4 9 10];
    else if ismember(subj_nums(s),[15])
        sessions{s}=[4 5 10 11];
    else if ismember(subj_nums(s),[22])
        sessions{s}=[4 5 9 10];
    else
        sessions{s}=[3 4 8 9];
        
        end
        end
    end
end

an={'roi'};

%ADD TOM CONDITIONS
prev_dir=pwd;
% cd('/younglab/studies/DIS_MVPA/behavioural/');
% firstSub=load([subjs{1} '.FB.1.mat']);
conditions.names={};
% for c=1:length(firstSub.spm_inputs)
%     conditions.names{end+1}=firstSub.spm_inputs(c).name;
% end
conditions.names{1}='Belief';conditions.names{2}='Photo';


% clear firstSub;

conditions.onsets=cell(2,length(subjs),4);
conditions.durations=cell(2,length(subjs),4);

for sub=1:length(subjs)
    cd(fullfile('/younglab/studies/MOR2/',subjs{sub},'results/fb_results/'));
    load('SPM.mat');
    for sessnum=1:4 %this corresponds to sessions{sub} index as well
        for cond=1:2
            conditions.onsets{cond}{sub}{sessnum}=SPM.Sess(sessnum).U(cond).ons;
            conditions.durations{cond}{sub}{sessnum}=SPM.Sess(sessnum).U(cond).dur;
        end
    end
    clear SPM;
end
cd(prev_dir);

%
% effect_names={'all','ASD','control','new_loc','old_loc'};
% effects=cell(length(effect_names),1);
% effects{1}=repmat([1],length(subjs),1);
% effects{2}=repmat([0],length(subjs),1); 
% effects{3}=repmat([0],length(subjs),1);
% effects{4}=repmat([0],length(subjs),1);
% effects{5}=repmat([0],length(subjs),1);
% for s=1:length(subjs)
%     if ismember(subj_nums(s),[15:24 29:31 39 44]) %ASD subjects
%         effects{2}(s)=1;
%     else %control subjects
%         effects{3}(s)=1;
%     end
%     if s < 16 %old localizer
%         effects{5}(s)=1;
%     else %new localizer
%         effects{4}(s)=1;
%     end
% end
% % global subjects_info;
% subjects_info=struct('effect_names',{effect_names},...
% 'effects',{effects});





toc; %time to set up
conn_BATCH_setup_MOR4(study, subjs, sessions, an,'MOR2_ROI_Analysis_tom','choose_roi','conditions');
toc; %time to complete setup step
conn_BATCH_firstlevel(study,'MOR2_ROI_Analysis_tom',{'corr'},0)
toc; %time to complete firstlevel setup
% conn_BATCH_secondlevel(study,'MOR4_ROI_Analysis_tom','acrosssubs',0,0,'ASDvControl',1)
% toc; %time to complete and process second-level analysis