function model_one_subject(study_folder, subj, behavtask, bidstask, runsorinfile, varargin)
% ==============================================================================
%
% This function can be used in a pbs script to run 
% the modeling preprocessing in parallel
% Uses modeling script for fmriprep preprocessed data
% e.g., model_one_subject('TPS_FMRIPREP','YOU_TPS_22','TPS_crn','tps','full_infile_TPS.csv')
%
% ==============================================================================
	
	addpath('/usr/public/spm/spm12');
	addpath(genpath('/data/younglw/lab/scripts'));
	% mfilepath = sprintf('/data/younglw/lab/%s/scripts', study_folder);
	% addpath(mfilepath);

    % parameters: study folder, subject name, behavioural.mat name; task name in bids, runs, ??
    % ex) model_one_subject('TPS_FMRIPREP','YOU_TPS_03','tom_localizer','tom',[1 2], 'full_TPS_infile.csv', 'no_art', 'clobber')
    younglab_model_spm12_sirius_BIDS(study_folder, subj, behavtask, bidstask, runsorinfile, varargin{:});

end %end function