clear all;

tic;

%SET UP BASIC PARAMETER INFO
study='XPECT';
fname='XPECT_con_ROI';
subj_nums=[3:11 13:15 17:20 22 24]; %excluding subs with...
%any missing TOM network rois (LTPJ/RTPJ/PC/DMPFC)
%and those that did a 2-run localizer
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['YOU_XPECT_' sprintf('%02d',s)];
    if ismember(s,[4])
        sessions{end+1}=[5 7 11 17 19];
    elseif ismember(s,[7])
        sessions{end+1}=[5 7 9 17 19];
    elseif ismember(s,[17])
        sessions{end+1}=[5 7 9 15 19];
    else
        sessions{end+1}=[5 7 9 15 17];
    end
end
% prev_dir=pwd;
% for i=1:length(subjs)
%         cd(fullfile('/younglab/studies',study,subjs{i},'3danat'))
%         img2nii;
% end
% cd(prev_dir);
an={'roi'};
%possible values: 'roi','seed','voxel'

%ADD EXPERIMENTAL CONDITIONS
%generate condition names from one mat file
prev_dir=pwd;
cd(['/younglab/studies/' study '/behavioural/']);
firstSub=load([subjs{1} '.XPECT.outcome.1.mat']); %<- this you will need to change
%depending on which conditions you're 
conditions.names={};
for c=1:length(firstSub.spm_inputs)
    conditions.names{end+1}=firstSub.spm_inputs(c).name;
end

clear firstSub;

%initialize condition cells 
%they will be of the form conditions.[fieldname]{condition}{subject}{session}
conditions.onsets=cell(11,length(subjs),5);
conditions.durations=cell(11,length(subjs),5);

%fill in the conditions information


for sub=1:length(subjs)
   for XPECTnum=1:5 %this corresponds to sessions{sub} index as well
       matname=load([subjs{sub} '.XPECT.outcome.' num2str(XPECTnum) '.mat']);
        for cond=1:6
            conditions.onsets{cond}{sub}{XPECTnum}=matname.spm_inputs(cond).ons;
            conditions.durations{cond}{sub}{XPECTnum}=[6 6];
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

% global subjects_info;
% subjects_info=struct('effect_names',{effect_names},...
% 'effects',{effects});




%RUN EMILY'S CONN SCRIPTS
%i usually only do setup and firstlevel, because it's nicer to explore
%second-level comparisons in the GUI
toc; %time to set up
conn_BATCH_setup_XPECT(study, subjs, sessions, an, fname,'choose_roi','conditions')
toc; %time to complete setup step
conn_BATCH_firstlevel_DIS(study,fname,{'corr'},0)
toc;

%CHECK THAT BATCH LOOKS RIGHT AND TELL CONN TO PROCESS IT
%you can also run the batch by switching the 0 for a 1 in the
%conn_batch_firstlevel function call above
%load(fullfile(fname,'.mat'));
%things you might want to check in the BATCH structure here:
    %are the 'done' fields = 1?
    %if Setup.roiextract=2, do you have both smoothed and unsmoothed
    %functional data in your subject directories?
    %do the fields that rely on your number of subjects (Setup.functionals,
    %Setup.structurals, Setup.subjects, Setup.conditions) all match?
%then uncomment to process through CONN:
% conn_batch(BATCH)
    
