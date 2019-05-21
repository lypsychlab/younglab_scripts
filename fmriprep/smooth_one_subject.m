function smooth_one_subject(study_folder, subj)
% ==============================================================================
%
% This function can be used in a pbs script to run 
% the smoothing preprocessing in parallel
% Uses smoothing script for fmriprep preprocessed data
%
% ==============================================================================
	
	addpath('/usr/public/spm/spm12');
	addpath(genpath('/data/younglw/lab/scripts/'));
	% mfilepath = sprintf('/data/younglw/lab/%s/scripts', study_folder);
	% addpath(mfilepath);

	younglab_preproc_spatial_spm12_BIDS_FT(study_folder, subj);

end %end function