clear all;

tic;
study='DIS_MVPA';
subj_nums=[3 4 5 6 7 8 9 10 ...
    11 12 13 14 15 16 20 ...
    22 23 24 27 28 29 30 31 34 ...
    38 40 42 45 46]; %this includes everyone w/no highlight, ...
%excludes those with irregular session numbering (17, 19, 41, 43)...
%and those with abnormal numbers of swrf* scans (32, 39, 44)
%subjects 18... missing RTPJ roi files
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
    if ismember(s,[5 9 16])
        sessions{end+1}=[10 12 14 20 22 24];
    elseif ismember(s,[7 14 24])
        sessions{end+1}=[12 14 16 22 24 26];
    elseif ismember(s,[37 44])
        sessions{end+1}=[6 8 10 16 18 20];
    elseif ismember(s,[38 39 40 42 45 46 47])
        sessions{end+1}=[4 6 8 14 16 18];
    else
        sessions{end+1}=[8 10 12 18 20 22];
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

%loading actual DIS conditions! whoa
prev_dir=pwd;
cd(['/younglab/studies/' study '/behavioural/']);
firstSub=load([subjs{1} '.DIS.1.mat']);
conditions.names={};
for c=1:length(firstSub.spm_inputs)
    conditions.names{end+1}=firstSub.spm_inputs(c).name;
end

clear firstSub;

conditions.onsets=cell(10,length(subjs),6);
conditions.durations=cell(10,length(subjs),6);

for sub=1:length(subjs)
    for DISnum=1:6 %this corresponds to sessions{sub} index as well
        matname=load([subjs{sub} '.DIS.' num2str(DISnum) '.mat']);
        for cond=1:10
            conditions.onsets{cond}{sub}{DISnum}=matname.spm_inputs(cond).ons;
            conditions.durations{cond}{sub}{DISnum}=matname.spm_inputs(cond).dur;
        end
        clear matname;
    end
end
cd(prev_dir);



%
effect_names={'all','ASD','control'};
effects=cell(length(effect_names),1);
effects{1}=repmat([1],length(subjs),1);
effects{2}=repmat([0],length(subjs),1); effects{3}=repmat([0],length(subjs),1);
for s=1:length(subjs)
    if ismember(subj_nums(s),[15:24 29:31 39 44]) %ASD subjects
        effects{2}(s)=1;
    else %control subjects
        effects{3}(s)=1;
    end
end
% global subjects_info;
subjects_info=struct('effect_names',{effect_names},...
'effects',{effects});





toc; %time to set up
conn_BATCH_setup_DIS(study, subjs, sessions, an,'DIS_ROI_Analysis','choose_roi','conditions','subjects_info');
toc; %time to complete setup step
conn_BATCH_firstlevel_DIS(study,'DIS_ROI_Analysis',{'corr'},0)
toc; %time to complete firstlevel setup
% conn_BATCH_secondlevel(study,'DIS_ROI_Analysis','acrosssubs',0,0,'ASDvControl',1)
% toc; %time to complete and process second-level analysis
