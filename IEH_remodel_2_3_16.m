clear all;

tic;

%SET UP BASIC PARAMETER INFO
study='IEHFMRI';taskname='ieh';
subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
% subj_nums=[5 7 13 14 16:22] % subjects with all 4 TOM ROIs
% subj_nums=[4 5 7 8 11:14 16:22 24 25] % RTPJ + LTPJ
% subj_nums=[5 7 8 13 14 16:22]; % RTPJ + DMPFC
% subj_nums=[4 5 7 11:14 16:22 24 25]; % RTPJ + PC
csv_data=csvread('/younglab/studies/IEHFMRI/subjs_sessions.csv',1,0);
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
    snum=find(csv_data(:,1)==subj_nums(s));
    sessions{end+1}=csv_data(snum,2:end-2);
end

% fixing the behavioral files:

% cd(fullfile('/younglab/studies/',study,'duration60secs_behavioral'));
% for s=1:length(subjs)
%     for r=1:8
%         load([subjs{s} '.' taskname '.' num2str(r) '.mat']);
%         spm_inputs(5).dur=repmat([10],length(spm_inputs(5).ons),1);
%         spm_inputs(6).dur=repmat([5],length(spm_inputs(6).ons),1);
%         save([subjs{s} '.' taskname '.' num2str(r) '.mat'],'spm_inputs','-append');
%     end
% end
% 
for thissub=1:length(subjs)
    try
%         younglab_model_spm12_parametric_noconds_ieh(study,subjs{thissub},taskname,sessions{thissub},'no_art');
          younglab_model_spm12_parametric_withconds_ieh(study,subjs{thissub},taskname,sessions{thissub},'no_art');
    
% toc;
    catch
        disp(['Unable to process subject ' subjs{thissub}]);
       continue
    end
end

% TEST CODE (uncomment to run sanity check on one subject's data):
% thissub=1;
% younglab_model_spm12_parametric_noruns_ieh(study,subjs{thissub},taskname,sessions{thissub},'clobber','no_art');
% younglab_model_spm12_parametric_noconds_ieh(study,subjs{thissub},taskname,sessions{thissub},'clobber','no_art');
% younglab_model_spm12_parametric_withconds_ieh(study,subjs{thissub},taskname,sessions{thissub},'clobber','no_art');

% toc;