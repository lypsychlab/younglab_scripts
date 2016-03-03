% Sets up CONN analysis for PSYCH-PHYS

clear all;

tic;

%SET UP BASIC PARAMETER INFO
study='PSYCH-PHYS';
fname='PSYCH-PHYS_TOM_S2V';
subj_nums=[3 4 6 7 9 11:15 17 19 22 24 34 41 44:47];
% exclude missing data: 21, 26
% exclude nonexistent: 36 25 37
% exclude missing behavioral: 43
% exclude missing ROIs: 16 18 20 23 27 29 30 33 3 5 8 10 28 31 32 35 38 40
% 42
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
    if ismember(s,[5 9 16 19])
        sessions{end+1}=[10 12 14 20 22 24];
    elseif ismember(s,[7 14 24])
        sessions{end+1}=[12 14 16 22 24 26];
    elseif ismember(s,[37 44])
        sessions{end+1}=[6 8 10 16 18 20];
    elseif ismember(s,[38 39 40 42 45 46 47])
        sessions{end+1}=[4 6 8 14 16 18];
    else if ismember(s,[17])
        sessions{end+1}=[8 12 14 20 22 24];
    else if ismember(s,[32])
        sessions{end+1}=[8 10 12 20 22 24];
    else if ismember(s,[41])
        sessions{end+1}=[4 8 10 16 18 20];
    else if ismember(s,[43])
        sessions{end+1}=[4 6 8 10 16 18];
    else
        sessions{end+1}=[8 10 12 18 20 22];
        end
        end
        end
        end
    end
end

%TOM:
subj_nums=[4 6 7 9 11:15 17 19 22 24 34];
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

an={'seed'};
%possible values: 'roi','seed','voxel'

%ADD EXPERIMENTAL CONDITIONS
%generate condition names from one mat file
% prev_dir=pwd;
% cd(['/mnt/englewood/data/' study '/behavioural/']);
% firstSub=load([subjs{1} '.DIS.1.mat']); %<- this you will need to change
% %depending on which conditions you're 
% conditions.names={};
% for c=1:length(firstSub.spm_inputs)
%     conditions.names{end+1}=firstSub.spm_inputs(c).name;
% end
% conditions.names{11}='rest';
% 
% clear firstSub;

%TOM:

prev_dir=pwd;
cd(['/mnt/englewood/data/' study '/behavioural/']);
firstSub=load([subjs{1} '.fb_sad.1.mat']);
conditions.names={};
for c=1:length(firstSub.spm_inputs)
    conditions.names{end+1}=firstSub.spm_inputs(c).name;
end
%initialize condition cells 
%they will be of the form conditions.[fieldname]{condition}{subject}{session}
% conditions.onsets=cell(11,length(subjs),6);
% conditions.durations=cell(11,length(subjs),6);
% 
% for sub=1:length(subjs)
%     for DISnum=1:6 %this corresponds to sessions{sub} index as well
%         matname=load([subjs{sub} '.DIS.' num2str(DISnum) '.mat']);
%         matname.spm_inputs(11).name='rest';
%         onset_list=[167];rest_start=[1];
%         for on=1:10
%             onset_list=[onset_list matname.spm_inputs(on).ons];
%             rest_start=[rest_start matname.spm_inputs(on).ons+12]; %this will be the vector of rest onsets
%         end
%         onset_list=sort(onset_list);rest_start=sort(rest_start);
% 
%         rest_durations=[];%this will be the vector of rest durations
%         for ron=1:length(rest_start)
%             rest_end=onset_list(ron)-1;
%             rest_durations=[rest_durations ((rest_end-rest_start(ron))+1)];
%         end
%         matname.spm_inputs(11).ons=rest_start;
%         matname.spm_inputs(11).dur=rest_durations;
%         for cond=1:11
%             conditions.onsets{cond}{sub}{DISnum}=matname.spm_inputs(cond).ons;
%             conditions.durations{cond}{sub}{DISnum}=matname.spm_inputs(cond).dur;
%         end
%         clear matname;
%     end
% end
% cd(prev_dir);

%TOM
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



%ADD BETWEEN-SUBJECTS VARIABLES
%for grouping subjects, encode inclusion in a group with a 1 at that
%subject's index
%for behavioral variables, use the actual data values, again indexed by
%subject
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




%RUN EMILY'S CONN SCRIPTS
%i usually only do setup and firstlevel, because it's nicer to explore
%second-level comparisons in the GUI
toc; %time to set up
conn_BATCH_setup_PSYCH(study, subjs, sessions, an,fname,'choose_roi','subjects_info','conditions')
toc; %time to complete setup step
conn_BATCH_firstlevel_PSYCH(study,fname,{'corr'},0)
toc;

%CHECK THAT BATCH LOOKS RIGHT AND TELL CONN TO PROCESS IT
%you can also run the batch by switching the 0 for a 1 in the
%conn_batch_firstlevel function call above
% load(fullfile(fname,'.mat'));
%things you might want to check in the BATCH structure here:
    %are the 'done' fields = 1?
    %if Setup.roiextract=2, do you have both smoothed and unsmoothed
    %functional data in your subject directories?
    %do the fields that rely on your number of subjects (Setup.functionals,
    %Setup.structurals, Setup.subjects, Setup.conditions) all match?
%then uncomment to process through CONN:
% conn_batch(BATCH)
    
