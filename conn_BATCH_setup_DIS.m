function filename = conn_BATCH_setup_DIS(varargin)
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
% filename:
% 	- specify a name for your .mat project.
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
% 	- specify a bandpass filter [lower upper]
% confounds:
% 	- load a .mat file containing information on your confounds (if absent, CONN defaults take over)
%subject_info:
%	- specify subject-level variables
% find_all_structures:
% 	- will search for all structures it can in directory /younglab/studies/study/conn
%   - if this parameter is absent and you do not manually specify some structures, you may encounter errors
%conditions:
%   - structure with fields .names, .onsets, .durations, and (optionally) .param/.filter
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
    subjects_info={};
    

	%binary defaults (user can specify non-default)
	default_mask=1;
	default_roi=1;

	%non-binary optionals (if user specifies this param, param value changes to user's specification)
	filt=0;
	confounds=0;
	conditions={};
	% steps=0;
	
	param_names={'filt'; 'confounds'; 'steps'; 'conditions'; 'subjects_info'};

	if nargin < 5
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
	filename=varargin{5};

	disp('Mandatory parameters set. Checking for optional parameters...')
	%check for optional parameters
	if nargin>5
		for param=6:nargin
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
                case 'subjects_info'
                    subjects_info=evalin('base',varargin{param});
                case 'conditions'
                    conditions=evalin('base',varargin{param});
			end
		end
	end
	
	disp('Optional parameters set. Beginning setup...')


	EXPERIMENT_ROOT_DIR='/younglab/studies/';
	cd(fullfile(EXPERIMENT_ROOT_DIR,study));mkdir('conn');cd(fullfile(pwd,'conn'));
	
	save_filename=[filename '.mat'];
	filename=fullfile(EXPERIMENT_ROOT_DIR,study,'conn',['conn_' filename '.mat']),
	clear BATCH;
	BATCH.filename=filename;
	BATCH.Setup.isnew=new;
	
	%1. SETUP

	BATCH.Setup.nsubjects=length(subjIDs);
    BATCH.Setup.RT=2;
    
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
		BATCH.Setup.voxelmaskfile='/software/spm12/toolbox/OldNorm/brainmask.nii'; 
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
	BATCH.Setup.outputfiles=[0,0,0,0,0,0];

	%fill in functional and structural data
	prev_dir=pwd;
    for sub=1:length(subjIDs)
        d = fullfile(EXPERIMENT_ROOT_DIR,study,subjIDs{sub},'3danat/');
	cd(d);
        p = fullfile(d,'ws*.nii');
        anatdir=dir(p);
        BATCH.Setup.structurals{sub}=fullfile(d,anatdir(1).name);
        for sess=1:length(sessions{sub}) %for every session specified for this subject
            sessdir=fullfile(EXPERIMENT_ROOT_DIR,study,subjIDs{sub},'bold',sprintf('%03d',sessions{sub}(sess)),'/');
           
            cd(sessdir); %go to that session's folder
            funcdir_tmp=dir('swraf*.img'); %find all the preprocessed images for that session (there will be many)
            funcdir=[];
            for fl=1:length(funcdir_tmp) %for all of those images
                funcdir=[funcdir ;fullfile(sessdir,funcdir_tmp(fl).name)]; %we want only the path to the name (funcdir_tmp contains other metadata)
            end
            BATCH.Setup.functionals{sub}{sess}=funcdir; %fill .functionals with ALL the .imgs for that session
        end
    end
	cd(prev_dir);
    
%     for s=1:BATCH.Setup.nsubjects
%         for sess=1:6
%             if length(BATCH.Setup.functionals{s}{sess})~=166
%                 sprintf('Problem with subject %s session %s functional data:',subjIDs{s},num2str(sessions{s}(sess)))
%                 sprintf('Incorrect number of scans present.')
%             end
%         end
%     end

	%specify source of unsmoothed BOLD signal volumes for ROI timeseries extraction
	%currently defaults to using BATCH.setup.functionals files without leading s
    %1: same as functionals
    %2: same as functionals, without leading 's'
    %3: programmatic rule defined by roiextract_rule field
    %4: other
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

	end

	%BATCH.Setup.rois
	%can use this to fill in ROI information from choose_roi structure
	%left unspecified, CONN will use ROI files in /.conn/rois
	if default_roi
		;
	else
		BATCH.Setup.rois=make_roi_struct_DIS(study,subjIDs); %
	end

	%if we want to explicitly specify covariate/confound/2nd-level information from previously created .mats:
	% if find_all_structures
	% 	find_all_structures(EXPERIMENT_ROOT_DIR,study,'conn');
	% end

	if ~isempty(subjects_info)
		BATCH.Setup.subjects=subjects_info;
	end

	if ~isempty(conditions)
		BATCH.Setup.conditions=conditions;
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
	sprintf('Saving BATCH as %s in directory %s.',save_filename,pwd)
	save(save_filename,'BATCH','an');
	
    %filename = filename(1:end-4);
end %end conn_BATCH_setup






%note for later: functions have their own workspaces so BATCH will NOT be shared across processing functions unless you save/load as .mat
