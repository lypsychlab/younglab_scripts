clear all;

tic;

%SET UP BASIC PARAMETER INFO
rootdir='/younglab/studies';
study='IEHFMRI';
fname='IEHFMRI_ROI_allrois_128';
mkdir(fullfile(rootdir,study,'logs'));
diary(fullfile(rootdir,study,'logs',['conn_run_IEH_' date '.txt']));
subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
% subj_nums=[5 7 13 14 16:22] % subjects with all 4 TOM ROIs
% subj_nums=[4 5 7 8 11:14 16:22 24 25] % RTPJ + LTPJ
% subj_nums=[5 7 8 13 14 16:22]; % RTPJ + DMPFC
% subj_nums=[4 5 7 11:14 16:22 24 25]; % RTPJ + PC

% exclude_subs=[4 7 13 16 25];

csv_data=csvread('/younglab/studies/IEHFMRI/subjs_sessions.csv',1,0);
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
    snum=find(csv_data(:,1)==subj_nums(s));
    sessions{end+1}=csv_data(snum,2:end-2);
%     if ismember(s,[5 9 16])
%         sessions{end+1}=[10 12 14 20 22 24];
%     elseif ismember(s,[7 14 24])
%         sessions{end+1}=[12 14 16 22 24 26];
%     elseif ismember(s,[37 44])
%         sessions{end+1}=[6 8 10 16 18 20];
%     elseif ismember(s,[38 39 40 42 45 46 47])
%         sessions{end+1}=[4 6 8 14 16 18];
%     else
%         sessions{end+1}=[8 10 12 18 20 22];
%     end
end

%TOM:
% subjs={};sessions={};
% for s=subj_nums
%     subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
%     if ismember(s,[5 9 16 19])
%         sessions{end+1}=[6 8 16 18];
%     elseif ismember(s,[7])
%         sessions{end+1}=[4 6 18 20];
%     elseif ismember(s,[14 24])
%         sessions{end+1}=[8 10 18 20];
%     elseif ismember(s,[17 32])
%         sessions{end+1}=[4 6 16 18];
%     else
%         sessions{end+1}=[4 6 14 16];
%     end
% end

an={'roi'};
%possible values: 'roi','seed','voxel'

% COPY GROUP ROIS INTO SUBJECT ROI FOLDERS
% roinames={'Hipp_L','Hipp_R','Parahipp_L','Parahipp_R','Retrosplenial_L','Retrosplenial_R'};
% cd(fullfile('/younglab/studies',study,'ROI'));
% for thisroi=1:length(roinames)
%     imgdir=dir(['*' roinames{thisroi} '*img']);
%     hdrdir=dir(['*' roinames{thisroi} '*hdr']);
%     for s=1:length(subjs)
%     copyfile(imgdir(1).name,fullfile('../',subjs{s},'roi',['ROI_' imgdir(1).name]));
%     copyfile(hdrdir(1).name,fullfile('../',subjs{s},'roi',['ROI_' hdrdir(1).name]));
%     end
% end
% 





%ADD EXPERIMENTAL CONDITIONS
%generate condition names from one mat file
prev_dir=pwd;
cd(['/younglab/studies/' study '/duration60secs_behavioral/']);
firstSub=load([subjs{1} '.ieh.1.mat']); 
conditions.names={};
for c=1:length(firstSub.spm_inputs)
    conditions.names{end+1}=firstSub.spm_inputs(c).name;
end
conditions.names{end+1}='rest';

clear firstSub;

%initialize condition cells 
%they will be of the form conditions.[fieldname]{condition}{subject}{session}
conditions.onsets=cell(7,length(subjs),8);
conditions.durations=cell(7,length(subjs),8);


TR=2.5;
for sub=1:length(subjs)
    for runnum=1:8 %this corresponds to sessions{sub} index as well
        matname=load([subjs{sub} '.ieh.' num2str(runnum) '.mat']);
        matname.spm_inputs(7).name='rest';
        onset_list=[167];rest_start=[1];
        for on=1:6
            onset_list=[onset_list matname.spm_inputs(on).ons/TR];
            rest_start=[rest_start matname.spm_inputs(on).ons+(60/TR)]; %this will be the vector of rest onsets
        end
        onset_list=sort(onset_list);rest_start=sort(rest_start);

        rest_durations=[];%this will be the vector of rest durations
        for ron=1:length(rest_start)
            rest_end=onset_list(ron)-1;
            rest_durations=[rest_durations ((rest_end-rest_start(ron))+1)];
        end
        matname.spm_inputs(7).ons=rest_start;
        matname.spm_inputs(7).dur=rest_durations;
        for cond=1:7
            conditions.onsets{cond}{sub}{runnum}=matname.spm_inputs(cond).ons/TR;
            conditions.durations{cond}{sub}{runnum}=matname.spm_inputs(cond).dur/TR;
        end
        clear matname;
    end
end
cd(prev_dir);





%ADD BETWEEN-SUBJECTS VARIABLES
%for grouping subjects, encode inclusion in a group with a 1 at that
%subject's index
%for behavioral variables, use the actual data values, again indexed by
%subject
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




%RUN EMILY'S CONN SCRIPTS
%i usually only do setup and firstlevel, because it's nicer to explore
%second-level comparisons in the GUI
toc; %time to set up
conn_BATCH_setup_IEH(study, subjs, sessions, an,fname,'choose_roi','conditions')
toc; %time to complete setup step
conn_BATCH_firstlevel_IEH(study,fname,{'corr'},0)
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
    diary off;