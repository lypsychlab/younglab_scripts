function conn_template(study,subj_tag,subj_nums,sessions,tname,analysis_type,fname)
% conn_template: helps you set up and process a batch file for CONN.
% The commented lines in the function give some idea of how these batch files look,
% if you're unsure of how to structure your input parameters.
% study: name of study (string)
% subj_tag: e.g. 'SAX_DIS' (string)
% subj_nums: subject numbers (array)
% sessions: cell array where each element is a numerical array of bold folder numbers
% tname: task name (string). Must match the name on your behavioral files.
% analysis_type: 'roi', 'seed', or 'voxel' depending on what you are running.
% fname: output name for your file, e.g. 'DIS_seedtovoxel_RTPJ'. 
% - your file will end up looking like "conn_" + fname + ".mat", and will be located
% in the "conn" subdirectory under your study folder.


tic;

%SET UP BASIC PARAMETER INFO
rootdir='/younglab/studies';
% study='IEHFMRI';
% fname='IEHFMRI_ROI_benoitVMPFC-MTL';
mkdir(fullfile(rootdir,study,'logs'));
diary(fullfile(rootdir,study,'logs',['conn_template_' date '.txt']));
% subj_nums=[4:8 11:14 16:22 24 25]; 



% csv_data=csvread('/younglab/studies/IEHFMRI/subjs_sessions.csv',1,0);
subjs={};
for s=1:length(subj_nums)
    subjs{end+1}=[subj_tag sprintf('%02d',subj_nums(s))];
    % snum=find(csv_data(:,1)==subj_nums(s));
    % sessions{end+1}=csv_data(snum,2:end-2);
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

an={analysis_type};
%possible values: 'roi','seed','voxel'

%ADD EXPERIMENTAL CONDITIONS
%generate condition names from one mat file
mkdir(fullfile(rootdir,study,'conn'));cd(fullfile(rootdir,study,'conn'));
prev_dir=pwd;
cd([rootdir study '/behavioural/']);
firstSub=load([subjs{1} '.' tname '.1.mat']); 
conditions.names={};
numconds=length(firstSub.spm_inputs);
for c=1:length(firstSub.spm_inputs)
    conditions.names{end+1}=firstSub.spm_inputs(c).name;
end

clear firstSub;

%initialize condition cells 
%they will be of the form conditions.[fieldname]{condition}{subject}{session}
conditions.onsets=cell(numconds,length(subjs),length(sessions{1}));
conditions.durations=cell(numconds,length(subjs),length(sessions{1}));

TR=2;ips=166;
for sub=1:length(subjs)
    for runnum=1:length(sessions{1}) %this corresponds to sessions{sub} index as well
        matname=load([subjs{sub} '.' tname '.' num2str(runnum) '.mat']);
        for cond=1:numconds
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
conn_BATCH_setup(study, subjs, sessions, an,fname,'choose_roi','conditions')
toc; %time to complete setup step
conn_BATCH_firstlevel(study,fname,{'corr'},0)
toc;
% you may need to make study-specific versions of these scripts, depending on what you are doing

%CHECK THAT BATCH LOOKS RIGHT AND TELL CONN TO PROCESS IT
%you can also run the batch by switching the 0 for a 1 in the
%conn_batch_firstlevel function call above
load(fullfile(fname,'.mat'));
keyboard;
%things you might want to check in the BATCH structure here:
    %are the 'done' fields = 1?
    %if Setup.roiextract=2, do you have both smoothed and unsmoothed
    %functional data in your subject directories?
    %do the fields that rely on your number of subjects (Setup.functionals,
    %Setup.structurals, Setup.subjects, Setup.conditions) all match?
%then uncomment to process through CONN:
conn_batch(BATCH)
    diary off;
end % end function
