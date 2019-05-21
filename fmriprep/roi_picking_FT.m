% add spm8 necessary for roi picking
addpath(genpath('/usr/public/spm/spm12'))
% addpath(genpath('/usr/public/spm/spm8'))

study = 'TPS_FMRIPREP'  
subj_name = "YOU_TPS_${sub_num}"

subjs = {}
for i = [1:21, 23:27, 29:30]
    subjs = [subjs, sprintf('/data/younglw/lab/FT_FMRIPREP/YOU_FIRSTTHIRD_%.02d', i)];
end

% add full path
% for i = 1:length(subjs)
% subjs{i} = ['/data/younglw/lab/FT_FMRIPREP/', subjs{i}];
% end

% roi picker example calls
% roi_picker_BIDS_FT(threshold,cluster_size, radius, contrast_number, roi_name, start_xyz(in string), subjects(in cell), results_dir)
% e.g.:
% roi_picker_BIDS_FT(.001,5,9,1,'RTPJ','[0; 0; 0]',{'/mindhive/saxelab/CUES3/SAX_cues3_05'},'CUES3','results/cues3_results_normed');

% save an ROI picking example here!
% roi_picker_BIDS_FT(.001,5,9,1,'RTPJ','[0; 0; 0]',subjs,study,'results/tom_localizer_results_normed')
% roi_picker_BIDS_FT(.001,5,9,1,'LTPJ','[0; 0; 0]',subjs,study,'results/tom_localizer_results_normed')
% roi_picker_BIDS_FT(.001,5,9,1,'PC','[0; 0; 0]',subjs,study,'results/tom_localizer_results_normed')
% roi_picker_BIDS_FT(.001,5,9,1,'DMPFC','[0; 0; 0]',subjs,study,'results/tom_localizer_results_normed')