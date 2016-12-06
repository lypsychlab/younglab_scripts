clear all;

tic;
study='DIS_MVPA';
subj_nums=[3:15 19 22:24 29 31 34]; %excluding subs with...
%any missing TOM network rois (LTPJ/RTPJ/PC/DMPFC)
%and those that did a 2-run localizer
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
    if ismember(s,[5 9 16 19])
        sessions{end+1}=[6 8 16 18];
    elseif ismember(s,[7])
        sessions{end+1}=[4 6 18 20];
    elseif ismember(s,[14 24])
        sessions{end+1}=[8 10 18 20];
    elseif ismember(s,[17 32])
        sessions{end+1}=[4 6 16 18];
    else
        sessions{end+1}=[4 6 14 16];
    end
end

an={'roi'};

%right now we're just treating all DIS as one condition
% cond_names={'DIS'};
% onsets=cell(1,length(subjs),6);
% durations=cell(1,length(subjs),6);
% for s = 1:length(subjs)
%    for sess=1:6
%        onsets{1}{s}{sess}=[0];
%        durations{1}{s}{sess}=[inf];
%    end
% end
% global conditions;
% conditions = struct('names',{cond_names},'onsets',{onsets},'durations',{durations});

%ADD TOM CONDITIONS
prev_dir=pwd;
cd('/younglab/studies/DIS_MVPA/behavioural/');
firstSub=load([subjs{1} '.fb_sad.1.mat']);
conditions.names={};
for c=1:length(firstSub.spm_inputs)
    conditions.names{end+1}=firstSub.spm_inputs(c).name;
end


clear firstSub;

conditions.onsets=cell(2,length(subjs),4);
conditions.durations=cell(2,length(subjs),4);

for sub=1:length(subjs)
    for sessnum=1:4 %this corresponds to sessions{sub} index as well
        matname=dir([subjs{sub} '.*f*.' num2str(sessnum) '.mat']);
        matname=matname.name;
        load(matname);
        for cond=1:2
            conditions.onsets{cond}{sub}{sessnum}=spm_inputs(cond).ons;
            conditions.durations{cond}{sub}{sessnum}=spm_inputs(cond).dur;
        end
    end
end
cd(prev_dir);

%
effect_names={'all','ASD','control','new_loc','old_loc'};
effects=cell(length(effect_names),1);
effects{1}=repmat([1],length(subjs),1);
effects{2}=repmat([0],length(subjs),1); 
effects{3}=repmat([0],length(subjs),1);
effects{4}=repmat([0],length(subjs),1);
effects{5}=repmat([0],length(subjs),1);
for s=1:length(subjs)
    if ismember(subj_nums(s),[15:24 29:31 39 44]) %ASD subjects
        effects{2}(s)=1;
    else %control subjects
        effects{3}(s)=1;
    end
    if s < 16 %old localizer
        effects{5}(s)=1;
    else %new localizer
        effects{4}(s)=1;
    end
end
% global subjects_info;
subjects_info=struct('effect_names',{effect_names},...
'effects',{effects});





toc; %time to set up
conn_BATCH_setup_DIS(study, subjs, sessions, an,'DIS_ROI_Analysis_tom_wraf','choose_roi','subjects_info','conditions');
toc; %time to complete setup step
conn_BATCH_firstlevel_DIS(study,'DIS_ROI_Analysis_tom_wraf',{'corr'},0)
toc; %time to complete firstlevel setup
% conn_BATCH_secondlevel(study,'DIS_ROI_Analysis','acrosssubs',0,0,'ASDvControl',1)
% toc; %time to complete and process second-level analysis