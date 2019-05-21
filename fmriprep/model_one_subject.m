function model_one_subject(study_folder, subj, behavtask, bidstask, runs)
% ==============================================================================
%
% This function can be used in a pbs script to run 
% the modeling preprocessing in parallel
% Uses modeling script for fmriprep preprocessed data
%
% ==============================================================================
	
	addpath('/usr/public/spm/spm12');
	addpath(genpath('/data/younglw/lab/scripts/'));
	mfilepath = sprintf('/data/younglw/lab/%s/scripts', study_folder);
	addpath(mfilepath);

    % parameters: study folder, subject name, behavioural.mat name; task name in bids, runs, ??
    % younglab_model_spm12_sirius_BIDS_FT(study_folder, subj, behavtask, bidstask, runs, 'no_art');
	younglab_model_spm12_sirius_BIDS_FT(study_folder, subj, behavtask, bidstask, runs, 'no_art', 'clobber');

end %end function