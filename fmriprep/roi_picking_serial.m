% Kevin Jiang
% Last updated: 5/29/19

% add spm necessary for roi picking
addpath(genpath('/usr/public/spm/spm12'))
% addpath(genpath('/usr/public/spm/spm8'))
addpath(genpath('/data/younglw/lab/scripts'))

%%%%%%%%%%%%%%%%%%%%%%%% Edit these for your study! %%%%%%%%%%%%%%%%%%%%%%%%%%%%
study_folder = 'TPS_FMRIPREP';
study_acronym = 'TPS';

subjs = {};  % note that subjs must contain full path here
% for i = [1 26 29 30]
%     subjs = [subjs, sprintf('/data/younglw/lab/%s/YOU_%s_%.02d', study_folder, study_acronym, i)];
% end
for i = [1]
    subjs = [subjs, sprintf('/data/younglw/lab/%s/YOU_%s_%.02d', study_folder, study_acronym, i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% roi picker example calls
% roi_picker_BIDS(threshold,cluster_size, radius, contrast_number, roi_name, start_xyz(in string), subjects(in cell), results_dir)
% e.g.:
% roi_picker_BIDS(.001,16,9,1,'RTPJ','[0; 0; 0]',{'/mindhive/saxelab/CUES3/SAX_cues3_05'},'CUES3','results/cues3_results_normed');

% some roi picking examples using roi_picker_BIDS
 %roi_picker_BIDS(.001,16,9,1,'LTPJ','[0; 0; 0]',subjs,study_folder,'results/tom_localizer_results_normed')

 roi_picker_BIDS(.001,16,9,1,'RTPJ','[0; 0; 0]',subjs,study_folder,'results/tom_localizer_results_normed')
 %roi_picker_BIDS(.001,16,9,1,'LTPJ','[0; 0; 0]',subjs,study_folder,'results/tom_localizer_results_normed')
 % roi_picker_BIDS(.001,16,9,1,'PC','[0; 0; 0]',subjs,study_folder,'results/tom_localizer_results_normed')
% roi_picker_BIDS(.001,16,9,1,'DMPFC','[0; 0; 0]',subjs,study_folder,'results/tom_localizer_results_normed')

% deprecated code
% % add full path
% for i = 1:length(subjs)
% 	subjs{i} = ['/data/younglw/lab/FT_FMRIPREP/', subjs{i}];
% end
