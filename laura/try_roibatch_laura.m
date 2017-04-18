clear all
% function roi_batch(subjects,roi_name,task_dir, loc_dir, contrast_num, win_secs, onsetdelay, highpass, meanwin)

% For example: roi_batch({'/younglab/studies/IEHFMRI/YOU_IEHFMRI_104', '/younglab/studies/IEHFMRI/YOU_IEHFMRI_105'},
	% 'RTPJ', '/results/ieh_results_normed_Dur60', '/results/tom_localizer_results_normed','1', 60, 6, 0, '0:0')
rootdir='/home/younglw/lab';
study='STOR';
subj_nums=[1:15]; % all subjects


subjs={};
for s=1:length(subj_nums)
    subjs{end+1}=fullfile(rootdir,study,['YOU_STOR_' sprintf('%02d',subj_nums(s))]);
end
subjs{end+1}=fullfile(rootdir,study,['YOU_STOR_TEST01']);


roi_batch(subjs,'DMPFC','results/STOR_results_normed',...
    'results/tom_localizer_results_normed','1',40,6,1,'18:24');

roi_batch(subjs,'VMPFC','results/STOR_results_normed',...
    'results/tom_localizer_results_normed','1',40,6,1,'18:24');