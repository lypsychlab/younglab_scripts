function conn_BATCH_setup(varargin)
% ================================================
% function conn_BATCH_setup completes the setup and preprocessing steps for a functional connectivity analysis using CONN v.15.
%
%
% For detailed instructions on CONN's batch-processing structure, consult the manual: CONN_fMRI_batch_manual.pdf
% To learn more about functional connectivity analyses from CONN's creators, read: WhitfieldGabrieli_&_NietoCastanon_2012.pdf
%
% Mandatory parameters:
% study: param for study name (string)
% subjIDs: param for subject numbers (cell array)
% sessions: param for sessions (cell array)
%	- sessions should have as many items as length(subjIDs)
% an: names of analyses to perform (cell array): 
%	'roi' for ROI-ROI
%	'seed' for seed-voxel
%	'voxel' for voxel-voxel
%
%On/Off Parameters:
%mask_subject:
%	  - 0: template masking (default)
%	  - 1: subject-specific template masking
%raw_units:
% 	- 0: percent signal change (default)
% 	- 1: raw units
% choose_mask: 
% 	- 0: use CONN's default masking procedure (default)
% 	- 1: specify masks
% choose_roi:
% 	- 0: use CONN's default ROIs (default)
% 	- 1: specify ROIs
% detrending:
% 	- 0: no detrending (default)
% despiking:
% 	- 0: no despiking (default)
% new:
% 	- 0: append to old project
% 	- 1: create new project (default)
% no_overwrite:
% 	- 0: overwrite on (default)
% 	- 1: do not overwrite
% spmfiles:
% 	- 0: do not look for SPM.mat files (default)
% 	- 1: search for SPM.mat files
%
%User-specified parameters:
% filename:
% 	- specify a name for your .mat project. (if absent, script auto-generates an ugly project name)
% filt:
% 	- specify a bandpass filter [lower upper]
% confounds:
% 	- load a .mat file containing information on your confounds (if absent, CONN defaults take over)
%subject_info:
%	- specify subject-level variables
% find_all_structures:
% 	- will search for all structures it can in directory /younglab/studies/study/conn
%   - if this parameter is absent and you do not manually specify some structures, you may encounter errors
%
%sample calls:
%
%conn_BATCH_setup('RACA',{'YOU_RACA_02' 'YOU_RACA_03'},{[13 15] [15 17]},{'roi'},'spmfiles')
%(use all CONN defaults, specify other info from SPM.mat files)
%conn_BATCH_setup('RACA',{'YOU_RACA_02' 'YOU_RACA_03'},{[13 15] [15 17]},{'roi' 'seed' 'voxel'},'filt=[0.01 0.1]','detrending','despiking')
%
%=================================================




	global EXPERIMENT_ROOT_DIR;
	
	%binary optionals:
	mask_subject=0;
	raw_units=0;
	detrending=0;
	despiking=0;
	new=1;
	overwrite=1;
	find_all_structures=0;
	spmfiles=0;

	%binary defaults (user can specify non-default)
	default_mask=1;
	default_roi=1;

	%non-binary optionals (if user specifies this param, param value changes to user's specification)
	filename={};
	filt=0;
	confounds=0;
	% steps=0;
	subjects_info={};
	
	param_names={'filt' 'confounds' 'steps' 'filename'};

	if nargin < 4
	    warning('conn_BATCH_setup requires at least 4 arguments: study, subject IDs, sessions, and analysis.')
	    warning('Run help(conn_BATCH_setup) for further guidance.' )
	    return;
	end

	if ~iscell(varargin{2})
    	varargin{2} = {varargin{2}};
	end

	if ~iscell(varargin{4})
    	varargin{4} = {varargin{4}};
	end

	%set mandatory parameters
	study=varargin{1};
	subjIDs=varargin{2};
	sessions=varargin{3};
	an=varargin{4};

	disp('Mandatory parameters set. Checking for optional parameters...')
	%check for optional parameters
	if nargin>4
		for param=5:nargin
			switch varargin{param}
				case 'mask_subject'
					mask_subject=1;
				case 'raw_units'
					raw_units=1;
				case 'detrending'
					detrending=1;
				case 'despiking'
					despiking=1;
				case 'not_new'
					new=0;
				case 'no_overwrite'
					overwrite=0;
				case 'find_all_structures'
					find_all_structures=1;
				case 'spmfiles'
					spmfiles=1;
				case 'choose_mask'
					default_mask=0;
					choose_mask='choose_mask';
				case 'choose_roi'
					default_roi=0;
					choose_roi='choose_roi';
				otherwise
					for i=1:length(param_names)
						if strfind(varargin{param}, param_names(i))
							eval(varargin{param});
						else
							warning('Unrecognized or incorrect parameter!')
							return;
						end
					end
			end
		end
	end
	
	disp('Optional parameters set. Beginning setup...')


	EXPERIMENT_ROOT_DIR='/younglab/studies/';
	cd(fullfile(EXPERIMENT_ROOT_DIR,study));mkdir('conn');cd(fullfile(pwd,'conn'));
	if isempty(filename) %makes a gross default filename
		filename=[study '_' strjoin(subjIDs,'.') '_' strjoin(an,'.')]; %strjoin DOES NOT WORK IN 2012b
	end
	filename=fullfile(EXPERIMENT_ROOT_DIR,study,'conn',['conn_' filename '.mat']),
	clear BATCH;
	BATCH.filename=filename;
	BATCH.Setup.isnew=new;
	% %if new:
	% BATCH.New.steps={};
	% for sub=1:length(subjIDs)
	% 	BATCH.New.structurals{sub}='%path to struct image'
	% 	for sess=1:length(sessions)
	% 		BATCH.New.functionals{sub}{sess}='path to func image';
	% 	end
	% end
	% BATCH.New.RT=;%specify inter-scan acquisition time in seconds
	% BATCH.New.sliceorder=[];
	% BATCH.New.template_structural='path to spms T1 image'
	% %check input parameters for steps
	% %if 'smoothing':
	% BATCH.New.FWHM=8; %specify fwhm
	% %if 'coregistration' or 'normalization'
	% BATCH.New.VOX=2; %specify voxel size

	%1. SETUP

	
    
	if spmfiles
		for sub=1:length(subjIDs)
			BATCH.Setup.spmfiles{sub}=fullfile(EXPERIMENT_ROOT_DIR,study,subjIDs{sub},'SPM.mat');
		end
	end

	BATCH.Setup.analyses=[];
	for a=1:length(an)
		switch an{a,:}
		case 'roi'
			BATCH.Setup.analyses=[BATCH.Setup.analyses 1];
		case 'seed'
			BATCH.Setup.analyses=[BATCH.Setup.analyses 2];
		case 'voxel'
			BATCH.Setup.analyses=[BATCH.Setup.analyses 3];
		otherwise
			warning('Incorrect input for analysis parameter. Must be: roi, seed, and/or voxel');
		end
	end

	%specify masking: subject-specific or generalized
	if mask_subject 
		BATCH.Setup.voxelmask=2;
	else
		BATCH.Setup.voxelmask=1;
		BATCH.Setup.voxelmaskfile='/software/spm12/toolbox/OldNorm/brainmask.nii'; %REPLACE MIDDLE ARG W/CORRECT PATH
	end

	%specify voxel resolution: 
	%3: same resolution/registration as functional volumes
	BATCH.Setup.voxelresolution=3;

	%specify units
	if raw_units 
		BATCH.Setup.analysisunits=2;
	else
		BATCH.Setup.analysisunits=1;
	end

	%specify output files 
	%currently defaults to: beta estimates of confounds, confound-corrected BOLD timeseries
	%for alternate options see manual p.29
	BATCH.Setup.outputfiles=[1,1,0,0,0,0];

	%fill in functional and structural data
	prev_dir=pwd;
	for sub=1:length(subjIDs)
        d = fullfile(EXPERIMENT_ROOT_DIR,study,subjIDs{sub},'3danat/');
        p = fullfile(d,'ws*.img');
		anatdir=dir(p);
		BATCH.Setup.structurals{sub}=fullfile(d,anatdir(1).name);
		for sess=1:length(sessions{sub}) %for every session specified for this subject
			sessdir=fullfile(EXPERIMENT_ROOT_DIR,study,subjIDs{sub},'bold',['0' num2str(sessions{sub}(sess)) '/']);
			cd(sessdir); %go to that session's folder
			funcdir_tmp=dir('swraf*.img'); %find all the preprocessed images for that session (there will be many)
			funcdir={};
            for fl=1:length(funcdir_tmp) %for all of those images 
				funcdir{fl}=fullfile(sessdir,funcdir_tmp(fl).name); %we want only the path to the name (funcdir contains other metadata)
			end
			BATCH.Setup.functionals{sub}{sess}=funcdir; %fill .functionals with ALL the .imgs for that session
		end
	end
	cd(prev_dir);

	%specify source of unsmoothed BOLD signal volumes for ROI timeseries extraction
	%currently defaults to using BATCH.setup.functionals files without leading s
	BATCH.Setup.roiextract=2;

	%BATCH.Setup.masks
	%can use this structure to fill in each subject's GM, WM, CSF masks
	%left unspecified, CONN will segment anatomical volumes appropriately
	if default_mask
		;
	else

		prev_dir=pwd;
		for sub=1:length(subjIDs)
	        d = fullfile(EXPERIMENT_ROOT_DIR,study,subjIDs{sub},'3danat/');
	        gr = fullfile(d,'c1*.nii');wh = fullfile(d,'c2*.nii');csf = fullfile(d,'c3*.nii');
			gr=dir(gr); wh=dir(wh);csf=dir(csf);
			BATCH.Setup.masks.Grey.files{sub}=gr(1).name;
			BATCH.Setup.masks.White.files{sub}=wh(1).name;
			BATCH.Setup.masks.CSF.files{sub}=csf(1).name;
			BATCH.Setup.masks.Grey.dimensions=1; %these correspond to CONN defaults; 
			BATCH.Setup.masks.White.dimensions=16; %please make your own copy of this script and change by hand...
			BATCH.Setup.masks.CSF.dimensions=16; %if you want different dimensions
		end
		cd(prev_dir);

		% find_structure('choose_mask',EXPERIMENT_ROOT_DIR,study);
		% BATCH.Setup.Grey.files=choose_mask.Grey.files; %each element of files should be a path to the desired image
		% BATCH.Setup.Grey.dimensions=choose_mask.Grey.dimensions; %CONN defaults are 1 component for Grey, 16 for White/CSF
		% BATCH.Setup.White.files=choose_mask.White.files;
		% BATCH.Setup.White.dimensions=choose_mask.White.dimensions;		
		% BATCH.Setup.CSF.files=choose_mask.CSF.files;
		% BATCH.Setup.CSF.dimensions=choose_mask.CSF.dimensions;

	end

	%BATCH.Setup.rois
	%can use this to fill in ROI information from choose_roi structure
	%left unspecified, CONN will use ROI files in /.conn/rois
	if default_roi
		;
	else
		BATCH.Setup.rois=make_roi_struct(study,subjIDs); %
		
		% find_structure('choose_roi',EXPERIMENT_ROOT_DIR,study);
		% BATCH.Setup.rois.names=choose_roi.names;
		% BATCH.Setup.rois.dimensions=choose_roi.dimensions;
		% for nm=1:length(choose_roi.names)
		% 	BATCH.Setup.rois.files{nm}=choose_roi.files{nm};
		% end
	end

	%we assume that conditions and covariates information is pulled from BATCH.setup.spmfiles

	%if we want to explicitly specify covariate/confound/2nd-level information from previously created .mats:
	% if find_all_structures
	% 	find_all_structures(EXPERIMENT_ROOT_DIR,study,'conn');
	% end

	if ~isempty(subjects_info)
		BATCH.Setup.subjects=subjects_info
	end

	%tell CONN to segment anatomical volumes and extract ROI data
	BATCH.Setup.done=1;

	%tell CONN whether to overwrite
	if overwrite
		BATCH.Setup.overwrite='Yes';
	else
		BATCH.Setup.overwrite='No';
	end

	%END SETUP
	disp('Setup complete. Begin preprocessing...')


	%BEGIN PREPROCESSING

	%specify bandpass filter
	if filt==0
		filt=[0.01 0.1];
    end
	
		BATCH.Preprocessing.filter=filt;
	

	%optionally choose to detrend/despike
	if detrending
		BATCH.Preprocessing.detrending=1;
	end

	if despiking
		BATCH.Preprocessing.despiking=1;
	end

	%specify confounds with confounds structure
	if confounds==0 %no confounds specified
		; %use CONN's defaults
	else
		find_structure('confounds',EXPERIMENT_ROOT_DIR,study)
		BATCH.Preprocessing.confounds.names=confounds.names;
		BATCH.Preprocessing.confounds.dimensions=confounds.dimensions;
		BATCH.Preprocessing.confounds.deriv=confounds.deriv;
	end

	%tell CONN to perform confound removal and filter the residual BOLD signal
	BATCH.Preprocessing.done=1;

	if overwrite
		BATCH.Preprocessing.overwrite='Yes';
	else
		BATCH.Preprocessing.overwrite='No';
	end

	%END PREPROCESSING
	disp('Preprocessing structure complete.')

	cd(fullfile(EXPERIMENT_ROOT_DIR,study,'conn')); 
	sprintf('Saving BATCH as %s in directory %s.',filename,pwd)
	save(filename,'BATCH','an');
	
end %end conn_BATCH_setup






%note for later: functions have their own workspaces so BATCH will NOT be shared across processing functions unless you save/load as .mat
