function conn_batch(batch)
% CONN_BATCH batch functionality for connectivity toolbox
% 
% CONN_BATCH(BATCH);
% where BATCH is a structure with fields (optional) New, Setup, Denoising,
% Analysis, and Results, will perform the specified steps.
% 
% BATCH structure fields:
%
% filename          : conn_*.mat project file
%
% New                 PERFORMS DATA PREPROCESSING (realignment/slicetiming/coregistration/segmentation/normalization/smoothing) AND INITIALIZES conn_* PROJECT
%
%   steps           : List of data preprocessing steps (cell array containing a subset of the following steps, in the desired order):
%                     steps={'default_mni','default_mniphase','default_ss','default_ssphase',...    % (default pipelines) 
%                         'structural_manualorient','structural_segment','structural_normalize',... % (individual steps) 
%                         'structural_segment&normalize','functional_removescans','functional_manualorient',...
%                         'functional_slicetime','functional_realign','functional_realign&unwarp',...
%                         'functional_realign&unwarp&phasemap','functional_art','functional_coregister',...
%                         'functional_segment','functional_normalize','functional_segment&normalize','functional_smooth'};
%                     If steps is left empty or unset a gui will prompt the user to specify the desired preprocessing pipeline 
%                   For backwards compatibility conn_batch also accepts the following step names (and it will run the old preprocessing pipeline in this case) 
%                     [{'segmentation','slicetiming','realignment','coregistration','normalization','smoothing','initialization'}];
%   functionals     : functionals{nsub}{nses} char array of functional volume files 
%   structurals     : structurals{nsub} char array of anatomical volume files 
%                     OR structurals{nsub}{nses} char array of anatomical session-specific volume files 
%   RT              : Repetition time (seconds) [2]
%   voxelsize       : target voxel size for resliced volumes (mm) [2]
%   boundingbox     : target bounding box for resliced volumes (mm) [-90,-126,-72;90,90,108] 
%   fwhm            : (functional_smooth) Smoothing factor (mm) [8]
%   coregtomean     : (functional_coregister/segment/normalize) 1: use mean volume (computed during realignment); 0: use first volume  
%   applytofunctional: (structural_normalize) 1/0: apply structural-normalization transformation to functional volumes as well 
%   sliceorder      : (functional_slicetime) acquisition order (vector of indexes; 1=first slice in image; note: use cell array for subject-specific vectors)
%                      alternatively sliceorder may also be defined as one of the following strings: 'ascending','descending','interleaved (middle-top)','interleaved (bottom-up)','interleaved (top-down)','interleaved (Siemens)'  
%                      alternatively sliceorder may also be defined as a vector containing the acquisition time in milliseconds for each slice (e.g. for multi-band sequences) 
%   art_thresholds  : (functional_art) ART thresholds for identifying outlier scans 
%                                           art_thresholds(1): threshold value for global-signal (z-value; default 9) 
%                                           art_thresholds(2): threshold value for subject-motion (mm; default 2) 
%                       additional options: art_thresholds(3): 1/0 global-signal threshold based on scan-to-scan changes in global-BOLD measure (default 1) 
%                                           art_thresholds(4): 1/0 subject-motion threshold based on scan-to-scan changes in subject-motion measure (default 1) 
%                                           art_thresholds(5): 1/0 subject-motion threhsold based on composite-movement measure (default 1) 
%                                           art_thresholds(6): 1/0 force interactive mode (ART gui) (default 0) 
%                                           art_thresholds(7): [only when art_threshold(5)=0] subject-motion threshold based on rotation measure 
%                           note: when art_threshold(5)=0, art_threshold(2) defines the threshold based on the translation measure, and art_threhsold(7) defines the threshold based on the rotation measure; otherwise art_threshold(2) defines the (single) threshold based on the composite-motion measure 
%   removescans     : (functional_removescans) number of initial scans to remove
%   reorient        : (functional/structural_manualorient) 3x3 transformation matrix
%   template_structural: (structural_normalize SPM8 only) anatomical template file for approximate coregistration [spm/template/T1.nii]
%   template_functional: (functional_normalize SPM8 only) functional template file for normalization [spm/template/EPI.nii]
%
%
% Setup               DEFINES EXPERIMENT SETUP AND PERFORMS INITIAL DATA EXTRACTION STEPS
%
%   isnew           : 1/0 is this a new conn project [0]
%   done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%   overwrite       : 1/0 overwrites target files if they exist [1]
%   spmfiles        : Optionally, spmfiles{nsub} is a char array pointing to the 'SPM.mat' source file to extract Setup information from for each subject (use alternatively spmfiles{nsub}{nses} for session-specific SPM.mat files) 
%   nsubjects       : Number of subjects
%   RT              : Repetition time (seconds) [2]
%   acquisitiontype : 1/0: Continuous acquisition of functional volumes [1] 
%   analyses        : Vector of index to analysis types (1: ROI-to-ROI; 2: Seed-to-voxel; 3: Voxel-to-voxel); 4: Dynamic FC [1,2,3,4] 
%   voxelmask       : Analysis mask type (voxel-level analyses): 1: Explicit mask (brainmask.nii); 2: Implicit mask (subject-specific) [1] 
%   voxelmaskfile   : Explicit mask file (only when voxelmask=1) [fullfile(fileparts(which('spm')),'apriori','brainmask.nii')] 
%   voxelresolution : Voxel resolution (voxel-level analyses): 1: Volume-based template (SPM; default 2mm isotropic or same as explicit mask if specified); 2: Same as structurals; 3: Same as functionals; 4: Surface-based template (Freesurfer) [1] 
%   analysisunits   : BOLD signal units: 1: PSC units (percent signal change); 2: raw units [1] 
%   outputfiles     : Optional output files (outputfiles(1): 1/0 creates confound beta-maps; outputfiles(2): 1/0 creates confound-corrected timeseries; outputfiles(3): 1/0 creates seed-to-voxel r-maps) ;outputfiles(4): 1/0 creates seed-to-voxel p-maps) ;outputfiles(5): 1/0 creates seed-to-voxel FDR-p-maps); outputfiles(6): 1/0 creates ROI-extraction REX files; [0,0,0,0,0,0] 
%   surfacesmoothing: Smoothing level for surface-based analyses (number of discrete diffusion steps) [50]
%   functionals     : functionals{nsub}{nses} char array of functional volume files (typically spatially smoothed BOLD signal volumes) 
%   structurals     : structurals{nsub} char array of structural volume files 
%                     OR structurals{nsub}{nses} char array of anatomical session-specific volume files 
%   roiextract      : Source of functional data for ROI timeseries extraction (typically unsmoothed BOLD signal volumes); 1: same as 'functionals' field; 2: same as 'functionals' field after removing leading 's' from filename; 3: other (define rule programmatically; see help conn_rulebasedfilename); 4: other (different set of functional volume files) [2] 
%   roiextract_rule : (for roiextract==3) regexprep(filename,roiextract_rule{2},roiextract_rule{3}) converts filenames in 'functionals' field (typically non-spatially smoothed BOLD signal volumes) to filenames that will be used when extracting BOLD signal ROI timeseries (if roiextract_rule{1}==2 filename is interpreted as a full path; if roiextract_rule{1}==1 filename is interpreted as only the file *name* -no file path, no file extension-)    
%   roiextract_functionals: (for roiextract==4) roiextract_functionals{nsub}{nses} char array of functional volume files (typically non-spatially smoothed BOLD signal volumes) to be used when extracting BOLD signal ROI timeseries 
%
%   masks
%     Grey          : masks.Grey{nsub} char array of grey matter mask volume file [defaults to Grey mask extracted from structural volume] 
%     White         : masks.White{nsub} char array of white matter mask volume file [defaults to White mask extracted from structural volume] 
%     CSF           : masks.CSF{nsub} char array of CSF mask volume file [defaults to CSF mask extracted from structural volume] 
%                   : each of these fields can also be defined as a structure with fields files/dimensions/etc. fields (see 'Setup.rois' below).
%   rois
%     names         : rois.names{nroi} char array of ROI name [defaults to ROI filename]
%     files         : rois.files{nroi}{nsub}{nses} char array of roi file (rois.files{nroi}{nsub} char array of roi file, to use the same roi for all sessions; or rois.files{nroi} char array of roi file, to use the same roi for all subjects)
%     dimensions    : rois.dimensions{nroi} number of ROI dimensions - # temporal components to extract from ROI [1]
%     mask          : rois.mask(nroi) 1/0 to mask with grey matter voxels [0] 
%     regresscovariates: rois.regresscovariates(nroi) 1/0 to regress known first-level covariates before computing PCA decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
%     roiextract    : rois.roiextract(nroi) 1/0 to use functional volumes specified in Setup.roiextract to extract BOLD signal within ROI [1] 
%
%   conditions
%     names         : conditions.names{ncondition} char array of condition name
%     onsets        : conditions.onsets{ncondition}{nsub}{nses} vector of condition onsets (in seconds)
%     durations     : conditions.durations{ncondition}{nsub}{nses} vector of condition durations (in seconds)
%     param         : conditions.param(ncondition) temporal modulation (0 for no temporal modulation; positive index to first-level covariate for other temporal interactions) 
%     filter        : conditions.filter{ncondition} temporal/frequency decomposition ([] for no decomposition; [low high] for fixed band-pass frequency filter; [N] for filter bank decompositoin with N frequency filters; [Duration Onsets] in seconds for sliding-window decomposition where Duration is a scalar and Onsets is a vector of two or more sliding-window onset values) 
%     missingdata   : 1/0 Allow subjects with missing condition data (empty onset/duration fields in *all* of the sessions) [0] 
%
%   covariates
%     names         : covariates.names{ncovariate} char array of covariate name
%     files         : covariates.files{ncovariate}{nsub}{nses} char array of covariate file 
%
%   subjects
%     effect_names  : subjects.effect_names{neffect} char array of second-level effect name
%     effects       : subjects.effects{neffect} vector of size [nsubjects,1] defining second-level effects
%
%   subjects
%     group_names  : subjects.group_names{ngroup} char array of second-level group name
%     groups       : subjects.group vector of size [nsubjects,1] (with values from 1 to ngroup) defining second-level groups
%
%
% Denoising       PERFORMS DENOISING STEPS (confound removal & filtering)
%
%   done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%   overwrite       : 1/0: overwrites target files if they exist [1]
%   filter          : vector with two elements specifying band pass filter: low-frequency & high-frequency cutoffs (Hz)
%   detrending      : 0/1/2/3: BOLD times-series polynomial detrending order (0: no detrending; 1: linear detrending; ... 3: cubic detrending) 
%   despiking       : 0/1/2: temporal despiking with a hyperbolic tangent squashing function (1:before regression; 2:after regression) [2] 
%   regbp           : 1/2: order of band-pass filtering step (1 = RegBP: regression followed by band-pass; 2 = Simult: simultaneous regression&band-pass) [1] 
%   confounds       : Cell array of confound names (alternatively see 'confounds.names' below)
%
%   confounds       : alternatively confounds can be a structure with fields
%     names         : confounds.names{nconfound} char array of confound name (confound names can be: 'Grey Matter','White Matter','CSF',any ROI name, any covariate name, or 'Effect of *' where * represents any condition name])
%     dimensions    : confounds.dimensions{nconfound} number of confound dimensions [defaults to using all dimensions available for each confound variable]
%     deriv         : confounds.deriv{nconfound} numnber of derivatives for each dimension [0]
%
%
% Analysis            PERFORMS FIRST-LEVEL ANALYSES (ROI-to-ROI and seed-to-voxel) 
%
%   done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%   overwrite       : 1/0: overwrites target files if they exist [1]
%   analysis_number : sequential indexes identifying each set of independent analyses [1] 
%   measure         : connectivity measure used, 1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)'; [1] 
%   weight          : within-condition weight, 1 = 'none', 2 = 'hrf', 3 = 'hanning'; [2] 
%   modulation      : temporal modulation, 0 = standard weighted GLM analyses; 1 = gPPI analyses of condition-specific temporal modulation factor, or a string for PPI analyses of other temporal modulation factor (same for all conditions; valid strings are ROI names and 1st-level covariate names)'; [0] 
%   type            : analysis type, 1 = 'ROI-to-ROI', 2 = 'Seed-to-Voxel', 3 = 'all'; [3] 
%   sources         : Cell array of sources names (seeds) (source names can be: any ROI name) (if this variable does not exist the toolbox will perform the analyses for all of the existing ROIs which are not defined as confounds in the Denoising step) 
%   conditions      : (for modulation==1 only) list of condition names to be simultaneously entered in gPPI model (leave empty for default 'all existing conditions') [] 
%
%   sources         : alternatively sources can be a structure with fields
%     names         : sources.names{nsource} char array of source names (seeds)
%     dimensions    : sources.dimensions{nsource} number of source dimensions [1]
%     deriv         : sources.deriv{nsource} number of derivatives for each dimension [0]
%     fbands        : sources.fbands{nsource} number of frequency bands for each dimension [1]
%
%
% Analysis            PERFORMS FIRST-LEVEL ANALYSES (voxel-to-voxel) 
%
%   done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%   overwrite       : 1/0: overwrites target files if they exist [1]
%   analysis_number : 0 (set this variable to 0 to identify voxel-to-voxel analyses) [0] 
%   measures        : Cell array of voxel-to-voxel measure names (type 'conn_v2v measures' for a list of default measures) (if this variable does not exist the toolbox will perform the analyses for all of the default voxel-to-voxel measures) 
%
%   measures        : alternatively voxel-to-voxel measures can be a structure with fields
%     names         : measures.names{nmeasure} char array of measure names 
%     type          : measures.type{nmeasure} measure type (0:local measures; 1: global measures) [1]
%     kernelsupport : measures.kernelsupport{nmeasure} local support (FWHM) of smoothing kernel [12]
%     kernelshape   : measures.kernelshape{nmeasure} kernel type (0: gaussian; 1: gradient; 2: laplacian) [1]
%     dimensions    : measures.dimensions{nmeasure} number of SVD dimensions to retain (dimensionality reduction) [16]
%
%
% Results             PERFORMS SECOND-LEVEL ANALYSES (ROI-to-ROI and Seed-to-Voxel analyses) 
%
%   done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%   analysis_number : sequential indexes identifying each set of independent analysis [1]
%   foldername      : folder to store the results
%
%   between_subjects
%     effect_names  : cell array of second-level effect names
%     contrast      : contrast vector (same size as effect_names)
%
%   between_conditions [defaults to multiple analyses, one per condition]
%     effect_names  : cell array of condition names (as in Setup.conditions.names)
%     contrast      : contrast vector (same size as effect_names)
%
%   between_sources    [defaults to multiple analyses, one per source]
%     effect_names  : cell array of source names (as in Analysis.regressors, typically appended with _1_1; generally they are appended with _N_M -where N is an index ranging from 1 to 1+derivative order, and M is an index ranging from 1 to the number of dimensions specified for each ROI; for example ROINAME_2_3 corresponds to the first derivative of the third PCA component extracted from the roi ROINAME) 
%     contrast      : contrast vector (same size as effect_names)
%
%
% Results             PERFORMS SECOND-LEVEL ANALYSES (Voxel-to-Voxel analyses) 
%
%   done            : 1/0: 0 defines fields only; 1 performs processing steps [0]
%   overwrite       : 1/0: overwrites target files if they exist [1]
%   analysis_number : 0 (set this variable to 0 to identify voxel-to-voxel analyses) [0]
%   foldername      : folder to store the results
%
%   between_subjects
%     effect_names  : cell array of second-level effect names
%     contrast      : contrast vector (same size as effect_names)
%
%   between_conditions [defaults to multiple analyses, one per condition]
%     effect_names  : cell array of condition names (as in Setup.conditions.names)
%     contrast      : contrast vector (same size as effect_names)
%
%   between_measures [defaults to multiple analyses, one per measure]
%     effect_names  : cell array of measure names (as in Analysis.measures) 
%     contrast      : contrast vector (same size as effect_names)
%
% See conn_batchexample*.m files for additional information and examples of use.
%

global CONN_x;

if iscell(batch),
    for nbatch=1:numel(batch),conn_batch(batch{nbatch});end
    return;
elseif numel(batch)>1,
    for nbatch=1:numel(batch),conn_batch(batch(nbatch));end
    return;
end
%% NEW step
if isfield(batch,'New'),
    OPTIONS=struct('RT',2,'FWHM',8,'VOX',2,'CONN_DISPLAY',0,'STRUCTURAL_TEMPLATE',fullfile(fileparts(which('spm')),'templates','T1.nii'),'FUNCTIONAL_TEMPLATE',fullfile(fileparts(which('spm')),'templates','EPI.nii'),'SO',[]);
    if isempty(dir(OPTIONS.FUNCTIONAL_TEMPLATE)), OPTIONS.FUNCTIONAL_TEMPLATE=fullfile(fileparts(which('spm')),'toolbox','OldNorm','EPI.nii'); end
    if isempty(dir(OPTIONS.STRUCTURAL_TEMPLATE)), OPTIONS.STRUCTURAL_TEMPLATE=fullfile(fileparts(which('spm')),'toolbox','OldNorm','T1.nii'); end
    if isfield(batch,'filename')&&~isempty(batch.filename),OPTIONS.CONN_NAME=batch.filename; end
    if isfield(batch.New,'center')&&~isempty(batch.New.cennter),OPTIONS.CENTER=batch.New.center;end
    if isfield(batch.New,'reorient')&&~isempty(batch.New.reorient),OPTIONS.REORIENT=batch.New.reorient;end
    if isfield(batch.New,'RT')&&~isempty(batch.New.RT),OPTIONS.RT=batch.New.RT;end; %obsolete
    if isfield(batch.New,'fwhm')&&~isempty(batch.New.fwhm),OPTIONS.FWHM=batch.New.fwhm;end
    if isfield(batch.New,'FWHM')&&~isempty(batch.New.FWHM),OPTIONS.FWHM=batch.New.FWHM;end
    if isfield(batch.New,'VOX')&&~isempty(batch.New.VOX),OPTIONS.VOX=batch.New.VOX;end
    if isfield(batch.New,'sliceorder')&&~isempty(batch.New.sliceorder),OPTIONS.SO=batch.New.sliceorder;end
    if isfield(batch.New,'removescans')&&~isempty(batch.New.removescans),OPTIONS.removescans=batch.New.removescans;end
    if isfield(batch.New,'coregtomean')&&~isempty(batch.New.coregtomean),OPTIONS.coregtomean=batch.New.coregtomean;end
    if isfield(batch.New,'applytofunctional')&&~isempty(batch.New.applytofunctional),OPTIONS.applytofunctional=batch.New.applytofunctional;end
    if isfield(batch.New,'art_thresholds')&&~isempty(batch.New.art_thresholds),OPTIONS.art_thresholds=batch.New.art_thresholds;end
    if isfield(batch.New,'steps')&&~isempty(batch.New.steps),OPTIONS.STEPS=batch.New.steps;end
    if isfield(batch.New,'template_structural')&&~isempty(batch.New.template_structural),OPTIONS.STRUCTURAL_TEMPLATE=batch.New.template_structural;end
    if isfield(batch.New,'template_functional')&&~isempty(batch.New.template_functional),OPTIONS.FUNCTIONAL_TEMPLATE=batch.New.template_functional;end
    if isfield(batch.New,'functionals')&&~isempty(batch.New.functionals),
        OPTIONS.FUNCTIONAL_FILES=batch.New.functionals;
    end
    if isfield(batch.New,'structurals')&&~isempty(batch.New.structurals),
        OPTIONS.STRUCTURAL_FILES=batch.New.structurals;
    end
    conn_setup_wizard(OPTIONS);
end

%% SETUP step
if isfield(batch,'Setup'),
    if isfield(batch,'filename'),
        if (isfield(batch.Setup,'isnew')&&batch.Setup.isnew)||isempty(dir(batch.filename)),
            conn('init');                   % initializes CONN_x structure
            CONN_x.filename=batch.filename;
        else,
            CONN_x.filename=batch.filename;
            CONN_x.gui=0;
            conn load;                      % loads existing conn_* project
            CONN_x.gui=1;
        end
    end
    
    if ~isfield(batch.Setup,'overwrite'),batch.Setup.overwrite='Yes';end
    if isscalar(batch.Setup.overwrite)&&~isstruct(batch.Setup.overwrite)&&ismember(double(batch.Setup.overwrite),[1 89 121]), batch.Setup.overwrite='Yes'; end
    if isfield(batch.Setup,'spmfiles')&&~isempty(batch.Setup.spmfiles),
        CONN_x.gui=struct('overwrite',batch.Setup.overwrite);
        conn_importspm(batch.Setup.spmfiles);
        CONN_x.gui=1;
    end
    if isfield(batch.Setup,'RT')&&~isempty(batch.Setup.RT),CONN_x.Setup.RT=batch.Setup.RT;end
    if isfield(batch.Setup,'nsubjects')&&~isempty(batch.Setup.nsubjects),
        if batch.Setup.nsubjects~=CONN_x.Setup.nsubjects, CONN_x.Setup.nsubjects=conn_merge(CONN_x.Setup.nsubjects,batch.Setup.nsubjects); end
%         CONN_x.Setup.nsubjects=batch.Setup.nsubjects;     % number of subjects
    end
    if isfield(batch.Setup,'acquisitiontype')&&~isempty(batch.Setup.acquisitiontype),
        CONN_x.Setup.acquisitiontype=1+(batch.Setup.acquisitiontype~=1);
    end
    if isfield(batch.Setup,'analyses'),
        CONN_x.Setup.steps=accumarray(batch.Setup.analyses(:),1,[4,1])';
    end
    if isfield(batch.Setup,'voxelmask')&&~isempty(batch.Setup.voxelmask),
        CONN_x.Setup.analysismask=batch.Setup.voxelmask;
    end
    if isfield(batch.Setup,'voxelmaskfile')&&~isempty(batch.Setup.voxelmaskfile),
        CONN_x.Setup.explicitmask=batch.Setup.voxelmaskfile;
    end
    if isfield(batch.Setup,'voxelresolution')&&~isempty(batch.Setup.voxelresolution),
        CONN_x.Setup.spatialresolution=batch.Setup.voxelresolution;
    end
    if isfield(batch.Setup,'analysisunits')&&~isempty(batch.Setup.analysisunits),
        CONN_x.Setup.analysisunits=batch.Setup.analysisunits;
    end
    if isfield(batch.Setup,'outputfiles'),
        CONN_x.Setup.outputfiles=batch.Setup.outputfiles;
    end
    if isfield(batch.Setup,'surfacesmoothing'),
        CONN_x.Setup.surfacesmoothing=batch.Setup.surfacesmoothing;
    end
    if isfield(batch.Setup,'functionals')&&~isempty(batch.Setup.functionals),
        for nsub=1:CONN_x.Setup.nsubjects,
            CONN_x.Setup.nsessions(nsub)=length(batch.Setup.functionals{nsub});
            for nses=1:CONN_x.Setup.nsessions(nsub),
                [CONN_x.Setup.functional{nsub}{nses},V]=conn_file(batch.Setup.functionals{nsub}{nses});
                CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
            end
        end
    end
    if isfield(batch.Setup,'roiextract')
        CONN_x.Setup.roiextract=batch.Setup.roiextract;
    end
    if isfield(batch.Setup,'roiextract_rule')
        CONN_x.Setup.roiextract_rule=batch.Setup.roiextract_rule;
    end
    if isfield(batch.Setup,'roiextract_functionals')
        for nsub=1:CONN_x.Setup.nsubjects,
            %CONN_x.Setup.nsessions(nsub)=length(batch.Setup.roiextract_functionals{nsub});
            for nses=1:CONN_x.Setup.nsessions(nsub),
                [CONN_x.Setup.roiextract_functional{nsub}{nses},V]=conn_file(batch.Setup.roiextract_functionals{nsub}{nses});
                %CONN_x.Setup.nscans{nsub}{nses}=prod(size(V));
            end
        end
    end
    if isfield(batch.Setup,'structurals')&&~isempty(batch.Setup.structurals),
        CONN_x.Setup.structural_sessionspecific=0; 
        for nsub=1:CONN_x.Setup.nsubjects,
            temp=batch.Setup.structurals{nsub};
            if ischar(temp), temp={temp}; end
            if numel(temp)>1, CONN_x.Setup.structural_sessionspecific=1; end
            for nses=1:CONN_x.Setup.nsessions(nsub),
                CONN_x.Setup.structural{nsub}{nses}=conn_file(temp{min(numel(temp),nses)});
            end
        end
    end
    if isfield(batch.Setup,'masks'),
        masks={'Grey','White','CSF'};
        for nmask=1:length(masks),
            if isfield(batch.Setup.masks,masks{nmask})&&~isempty(batch.Setup.masks.(masks{nmask})),
                if ~isstruct(batch.Setup.masks.(masks{nmask})),
                    subjectspecific=0;
                    sessionspecific=0;
                    temp1=batch.Setup.masks.(masks{nmask});
                    if ischar(temp1), temp1={temp1}; end
                    if numel(temp1)>1||CONN_x.Setup.nsubjects==1, subjectspecific=1; end
                    for nsub=1:CONN_x.Setup.nsubjects,
                        temp2=temp1{min(numel(temp1),nsub)};
                        if ischar(temp2), temp2={temp2}; end
                        if numel(temp2)>1, sessionspecific=1; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            CONN_x.Setup.rois.files{nsub}{nmask}{nses}=conn_file(temp2{min(numel(temp2),nses)});
                        end
                    end
                    CONN_x.Setup.rois.subjectspecific(nmask)=subjectspecific;
                    CONN_x.Setup.rois.sessionspecific(nmask)=sessionspecific;
                else,
                    subjectspecific=0;
                    sessionspecific=0;
                    temp1=batch.Setup.masks.(masks{nmask}).files;
                    if ischar(temp1), temp1={temp1}; end
                    if numel(temp1)>1||CONN_x.Setup.nsubjects==1, subjectspecific=1; end
                    for nsub=1:CONN_x.Setup.nsubjects,
                        temp2=temp1{min(numel(temp1),nsub)};
                        if ischar(temp2), temp2={temp2}; end
                        if numel(temp2)>1, sessionspecific=1; end
                        for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                            CONN_x.Setup.rois.files{nsub}{nmask}{nses}=conn_file(temp2{min(numel(temp2),nses)});
                        end
                    end
                    if isfield(batch.Setup.masks.(masks{nmask}),'dimensions'), CONN_x.Setup.rois.dimensions{nmask}=batch.Setup.masks.(masks{nmask}).dimensions; end
                    if isfield(batch.Setup.masks.(masks{nmask}),'regresscovariates'), CONN_x.Setup.rois.regresscovariates(nmask)=batch.Setup.masks.(masks{nmask}).regresscovariates; end
                    if isfield(batch.Setup.masks.(masks{nmask}),'roiextract'), CONN_x.Setup.rois.unsmoothedvolumes(nmask)=batch.Setup.masks.(masks{nmask}).roiextract; end
                    CONN_x.Setup.rois.subjectspecific(nmask)=subjectspecific;
                    CONN_x.Setup.rois.sessionspecific(nmask)=sessionspecific;
                end;
            end
        end
    end
%     if isfield(batch.Setup,'masks')&&isfield(batch.Setup.masks,'Grey')&&~isempty(batch.Setup.masks.Grey),for nsub=1:CONN_x.Setup.nsubjects,CONN_x.Setup.rois.files{nsub}{1}=conn_file(batch.Setup.masks.Grey{nsub});end; end
%     if isfield(batch.Setup,'masks')&&isfield(batch.Setup.masks,'White')&&~isempty(batch.Setup.masks.White),for nsub=1:CONN_x.Setup.nsubjects,CONN_x.Setup.rois.files{nsub}{2}=conn_file(batch.Setup.masks.White{nsub});end; end
%     if isfield(batch.Setup,'masks')&&isfield(batch.Setup.masks,'CSF')&&~isempty(batch.Setup.masks.CSF),for nsub=1:CONN_x.Setup.nsubjects,CONN_x.Setup.rois.files{nsub}{3}=conn_file(batch.Setup.masks.CSF{nsub});end; end
    if isfield(batch.Setup,'rois'),%&&~isempty(batch.Setup.rois),
        if ~isstruct(batch.Setup.rois), 
            temp=batch.Setup.rois;
            batch.Setup.rois=struct;
            batch.Setup.rois.files=temp;
            for n1=1:length(temp), ttemp=temp{n1}; while iscell(ttemp), ttemp=ttemp{1}; end; [nill,name,nameext]=fileparts(ttemp); batch.Setup.rois.names{n1}=name;end; 
        end
        n0=3;%length(CONN_x.Setup.rois.names)-1; % disregards existing rois?
        for n1=1:length(batch.Setup.rois.files),
            subjectspecific=0;
            sessionspecific=0;
            temp1=batch.Setup.rois.files{n1};
            if ischar(temp1), temp1={temp1}; end
            if numel(temp1)>1||CONN_x.Setup.nsubjects==1, subjectspecific=1; end
            for nsub=1:CONN_x.Setup.nsubjects, 
                temp2=temp1{min(numel(temp1),nsub)};
                if ischar(temp2), temp2={temp2}; end
                if numel(temp2)>1, sessionspecific=1; end
                for nses=1:CONN_x.Setup.nsessions(min(numel(CONN_x.Setup.nsessions),nsub))
                    [nill,name,nameext]=fileparts(temp2{min(numel(temp2),nses)});
                    %[V,str,icon]=conn_getinfo(batch.Setup.rois.files{n1}{nsub});
                    %CONN_x.Setup.rois.files{nsub}{n0+n1}={batch.Setup.rois.files{n1}{nsub},str,icon};
                    CONN_x.Setup.rois.files{nsub}{n0+n1}{nses}=conn_file(temp2{min(numel(temp2),nses)});
                end
            end
            if ~isfield(batch.Setup.rois,'names')||length(batch.Setup.rois.names)<n1||isempty(batch.Setup.rois.names{n1}), batch.Setup.rois.names{n1}=name; end
            if ~isfield(batch.Setup.rois,'dimensions')||length(batch.Setup.rois.dimensions)<n1||isempty(batch.Setup.rois.dimensions{n1}), batch.Setup.rois.dimensions{n1}=1; end
            if ~isfield(batch.Setup.rois,'mask')||length(batch.Setup.rois.mask)<n1, batch.Setup.rois.mask(n1)=0; end
            if ~isfield(batch.Setup.rois,'multiplelabels')||length(batch.Setup.rois.multiplelabels)<n1, batch.Setup.rois.multiplelabels(n1)=(strcmp(nameext,'.img')|strcmp(nameext,'.nii')|strcmp(nameext,'.mgz'))&(~isempty(dir(conn_prepend('',CONN_x.Setup.rois.files{1}{n0+n1}{1}{1},'.txt')))|~isempty(dir(conn_prepend('',CONN_x.Setup.rois.files{1}{n0+n1}{1}{1},'.csv')))|~isempty(dir(conn_prepend('',CONN_x.Setup.rois.files{1}{n0+n1}{1}{1},'.xls')))); end
            if ~isfield(batch.Setup.rois,'regresscovariates')||length(batch.Setup.rois.regresscovariates)<n1, batch.Setup.rois.regresscovariates(n1)=double(batch.Setup.rois.dimensions{n1}>1); end
            if ~isfield(batch.Setup.rois,'roiextract')||length(batch.Setup.rois.roiextract)<n1, batch.Setup.rois.roiextract(n1)=1; end
            CONN_x.Setup.rois.names{n0+n1}=batch.Setup.rois.names{n1}; CONN_x.Setup.rois.names{n0+n1+1}=' ';
            CONN_x.Setup.rois.dimensions{n0+n1}=batch.Setup.rois.dimensions{n1};
            CONN_x.Setup.rois.mask(n0+n1)=batch.Setup.rois.mask(n1);
            CONN_x.Setup.rois.subjectspecific(n0+n1)=subjectspecific;
            CONN_x.Setup.rois.sessionspecific(n0+n1)=sessionspecific;
            CONN_x.Setup.rois.multiplelabels(n0+n1)=batch.Setup.rois.multiplelabels(n1);
            CONN_x.Setup.rois.regresscovariates(n0+n1)=batch.Setup.rois.regresscovariates(n1);
            CONN_x.Setup.rois.unsmoothedvolumes(n0+n1)=batch.Setup.rois.roiextract(n1);
        end
        for nsub=1:CONN_x.Setup.nsubjects,% disregards existing rois
            CONN_x.Setup.rois.files{nsub}=CONN_x.Setup.rois.files{nsub}(1:n0+length(batch.Setup.rois.files)); 
        end
        CONN_x.Setup.rois.names=CONN_x.Setup.rois.names(1:n0+length(batch.Setup.rois.files)+1);
        CONN_x.Setup.rois.names{end}=' ';
        CONN_x.Setup.rois.dimensions=CONN_x.Setup.rois.dimensions(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.mask=CONN_x.Setup.rois.mask(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.subjectspecific=CONN_x.Setup.rois.subjectspecific(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.sessionspecific=CONN_x.Setup.rois.sessionspecific(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.multiplelabels=CONN_x.Setup.rois.multiplelabels(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.regresscovariates=CONN_x.Setup.rois.regresscovariates(1:n0+length(batch.Setup.rois.files));
        CONN_x.Setup.rois.unsmoothedvolumes=CONN_x.Setup.rois.unsmoothedvolumes(1:n0+length(batch.Setup.rois.files));
    elseif isfield(batch.Setup,'isnew')&&batch.Setup.isnew,
        conn importrois;
    end

    if isfield(batch.Setup,'conditions')&&~isempty(batch.Setup.conditions),
        CONN_x.Setup.conditions.names={batch.Setup.conditions.names{:},' '};
        for nsub=1:CONN_x.Setup.nsubjects,
            for nconditions=1:length(batch.Setup.conditions.names),
                for nses=1:CONN_x.Setup.nsessions(nsub),
                    if isfield(batch.Setup.conditions,'onsets')
                        CONN_x.Setup.conditions.values{nsub}{nconditions}{nses}={batch.Setup.conditions.onsets{nconditions}{nsub}{nses},batch.Setup.conditions.durations{nconditions}{nsub}{nses}};
                    else
                        CONN_x.Setup.conditions.values{nsub}{nconditions}{nses}={0,inf};
                    end
                end
            end
        end
        if isfield(batch.Setup.conditions,'param')
            CONN_x.Setup.conditions.param=batch.Setup.conditions.param;
        else
            CONN_x.Setup.conditions.param=zeros(1,length(batch.Setup.conditions.names));
        end
        if isfield(batch.Setup.conditions,'filter')
            CONN_x.Setup.conditions.filter=batch.Setup.conditions.filter;
        else
            CONN_x.Setup.conditions.filter=cell(1,length(batch.Setup.conditions.names));
        end
    end
    if isfield(batch.Setup,'conditions')&&isfield(batch.Setup.conditions,'missingdata'), CONN_x.Setup.conditions.missingdata=batch.Setup.conditions.missingdata; end
    
    if isfield(batch.Setup,'covariates')&&~isempty(batch.Setup.covariates),
        CONN_x.Setup.l1covariates.names={batch.Setup.covariates.names{:},' '};
        for nsub=1:CONN_x.Setup.nsubjects,
            for nl1covariates=1:length(batch.Setup.covariates.files),
                for nses=1:CONN_x.Setup.nsessions(nsub),
                    CONN_x.Setup.l1covariates.files{nsub}{nl1covariates}{nses}=conn_file(batch.Setup.covariates.files{nl1covariates}{nsub}{nses});
                end
            end
        end
    end
    if isfield(batch.Setup,'covariates_add')&&~isempty(batch.Setup.covariates_add),
        nl0=numel(CONN_x.Setup.l1covariates.names)-1;
        CONN_x.Setup.l1covariates.names={CONN_x.Setup.l1covariates.names{1:nl0} batch.Setup.covariates_add.names{:},' '};
        for nsub=1:CONN_x.Setup.nsubjects,
            for nl1covariates=1:length(batch.Setup.covariates_add.files),
                for nses=1:CONN_x.Setup.nsessions(nsub),
                    CONN_x.Setup.l1covariates.files{nsub}{nl0+nl1covariates}{nses}=conn_file(batch.Setup.covariates_add.files{nl1covariates}{nsub}{nses});
                end
            end
        end
    end
    if isfield(batch.Setup,'subjects')&&~isempty(batch.Setup.subjects),
        CONN_x.Setup.l2covariates.names={' '};
        CONN_x.Setup.l2covariates.values=repmat({{}},[CONN_x.Setup.nsubjects,1]);
        if isfield(batch.Setup.subjects,'group_names')&&~isempty(batch.Setup.subjects.group_names),
            for ngroup=1:length(batch.Setup.subjects.group_names),
                idx=strmatch(batch.Setup.subjects.group_names{ngroup},CONN_x.Setup.l2covariates.names,'exact');
                if isempty(idx),
                    nl2covariates=length(CONN_x.Setup.l2covariates.names);
                    CONN_x.Setup.l2covariates.names{nl2covariates}=batch.Setup.subjects.group_names{ngroup};
                    CONN_x.Setup.l2covariates.names{nl2covariates+1}=' ';
                else, nl2covariates=idx;end
                for nsub=1:CONN_x.Setup.nsubjects,
                    CONN_x.Setup.l2covariates.values{nsub}{nl2covariates}=(batch.Setup.subjects.groups(nsub)==ngroup);
                end
            end
        end
        if isfield(batch.Setup.subjects,'effect_names')&&~isempty(batch.Setup.subjects.effect_names),
            for neffect=1:length(batch.Setup.subjects.effect_names),
                idx=strmatch(batch.Setup.subjects.effect_names{neffect},CONN_x.Setup.l2covariates.names,'exact');
                if isempty(idx),
                    nl2covariates=length(CONN_x.Setup.l2covariates.names);
                    CONN_x.Setup.l2covariates.names{nl2covariates}=batch.Setup.subjects.effect_names{neffect};
                    CONN_x.Setup.l2covariates.names{nl2covariates+1}=' ';
                else, nl2covariates=idx;end
                for nsub=1:CONN_x.Setup.nsubjects,
                    CONN_x.Setup.l2covariates.values{nsub}{nl2covariates}=batch.Setup.subjects.effects{neffect}(nsub);
                end
            end
        end
    end
    
    if isfield(batch.Setup,'done')&&batch.Setup.done,
        conn save;
        if ~isfield(batch.Setup,'overwrite'), batch.Setup.overwrite='Yes'; end
        if isscalar(batch.Setup.overwrite)&&~isstruct(batch.Setup.overwrite)&&ismember(double(batch.Setup.overwrite),[1 89 121]), batch.Setup.overwrite='Yes'; end
        CONN_x.gui=struct('overwrite',batch.Setup.overwrite);
        conn_process Setup;
        CONN_x.gui=1;
        conn save;
    else,
        if isfield(batch,'filename'),
            conn save;
        end
    end
end

%% DENOISING step
if isfield(batch,'Preprocessing')&&~isfield(batch,'Denoising'),batch.Denoising=batch.Preprocessing; end
if isfield(batch,'Denoising'),
    if isfield(batch,'filename'),
        CONN_x.filename=batch.filename;
        CONN_x.gui=0;
        conn load;                      % loads existing conn_* project
        CONN_x.gui=1;
    end
    if isfield(batch.Denoising,'filter')&&~isempty(batch.Denoising.filter),
        CONN_x.Preproc.filter=batch.Denoising.filter;          % frequency filter (band-pass values, in Hz)
    end
    if isfield(batch.Denoising,'detrending')&&~isempty(batch.Denoising.detrending),
        CONN_x.Preproc.detrending=batch.Denoising.detrending;          
    end
    if isfield(batch.Denoising,'despiking')&&~isempty(batch.Denoising.despiking),
        CONN_x.Preproc.despiking=batch.Denoising.despiking;          
    end
    if isfield(batch.Denoising,'regbp')&&~isempty(batch.Denoising.regbp),
        CONN_x.Preproc.regbp=batch.Denoising.regbp;          
    end
    if isfield(batch.Denoising,'confounds')&&~isempty(batch.Denoising.confounds),
        CONN_x.Preproc.confounds.names=batch.Denoising.confounds.names;
        if isfield(batch.Denoising.confounds,'dimensions')&&~isempty(batch.Denoising.confounds.dimensions), CONN_x.Preproc.confounds.dimensions=batch.Denoising.confounds.dimensions; else, CONN_x.Preproc.confounds.dimensions={}; end
        if isfield(batch.Denoising.confounds,'deriv')&&~isempty(batch.Denoising.confounds.deriv), CONN_x.Preproc.confounds.deriv=batch.Denoising.confounds.deriv; else, CONN_x.Preproc.confounds.deriv={}; end
    end
    
    if isfield(batch.Denoising,'done')&&batch.Denoising.done,
        conn save;
        if ~isfield(batch.Denoising,'overwrite'), batch.Denoising.overwrite='Yes'; end
        if isscalar(batch.Denoising.overwrite)&&~isstruct(batch.Denoising.overwrite)&&ismember(double(batch.Denoising.overwrite),[1 89 121]), batch.Denoising.overwrite='Yes'; end
        CONN_x.gui=struct('overwrite',batch.Denoising.overwrite);
        conn_process Preprocessing;
        CONN_x.gui=1;
        conn save;
    else,
        if isfield(batch,'filename'),
            conn save;
        end
    end
end

%% ANALYSIS step
if isfield(batch,'Analysis'),
    if isfield(batch,'filename'),
        CONN_x.filename=batch.filename;
        CONN_x.gui=0;
        conn load;                      % loads existing conn_* project
        CONN_x.gui=1;
    end
    if isfield(batch.Analysis,'sources'),
        if ~isfield(batch.Analysis,'analysis_number')||isempty(batch.Analysis.analysis_number),batch.Analysis.analysis_number=1; end
        if ~isfield(batch.Analysis,'modulation')||isempty(batch.Analysis.modulation),batch.Analysis.modulation=0; end
        if ~isfield(batch.Analysis,'measure')||isempty(batch.Analysis.measure),batch.Analysis.measure=1; end
        if ~isfield(batch.Analysis,'weight')||isempty(batch.Analysis.weight),batch.Analysis.weight=2; end
        if ~isfield(batch.Analysis,'type')||isempty(batch.Analysis.type),batch.Analysis.type=3; end
        if ~isfield(batch.Analysis,'conditions'),batch.Analysis.conditions=[]; end
        CONN_x.Analysis=batch.Analysis.analysis_number;
        CONN_x.Analyses(CONN_x.Analysis).modulation=batch.Analysis.modulation;
        CONN_x.Analyses(CONN_x.Analysis).measure=batch.Analysis.measure;
        CONN_x.Analyses(CONN_x.Analysis).weight=batch.Analysis.weight;
        CONN_x.Analyses(CONN_x.Analysis).type=batch.Analysis.type;
        CONN_x.Analyses(CONN_x.Analysis).conditions=batch.Analysis.conditions;
        if isempty(batch.Analysis.sources),
            CONN_x.Analyses(CONN_x.Analysis).regressors.names={};
        elseif ~isstruct(batch.Analysis.sources),
            CONN_x.Analyses(CONN_x.Analysis).regressors.names=batch.Analysis.sources;
            CONN_x.Analyses(CONN_x.Analysis).regressors.dimensions=repmat({1},size(batch.Analysis.sources));
            CONN_x.Analyses(CONN_x.Analysis).regressors.deriv=repmat({0},size(batch.Analysis.sources));
            CONN_x.Analyses(CONN_x.Analysis).regressors.types=repmat({'roi'},size(batch.Analysis.sources));
            CONN_x.Analyses(CONN_x.Analysis).regressors.fbands=repmat({1},size(batch.Analysis.sources));
        else
            CONN_x.Analyses(CONN_x.Analysis).regressors.names=batch.Analysis.sources.names;
            CONN_x.Analyses(CONN_x.Analysis).regressors.dimensions=batch.Analysis.sources.dimensions;
            CONN_x.Analyses(CONN_x.Analysis).regressors.deriv=batch.Analysis.sources.deriv;
            CONN_x.Analyses(CONN_x.Analysis).regressors.types=repmat({'roi'},size(batch.Analysis.sources.names));
            if isfield(batch.Analysis.sources,'fbands')
                CONN_x.Analyses(CONN_x.Analysis).regressors.fbands=batch.Analysis.sources.fbands;
            else
                CONN_x.Analyses(CONN_x.Analysis).regressors.fbands=repmat({1},1,numel(batch.Analysis.sources.names));
            end
        end
    end
    if isfield(batch.Analysis,'measures')
        batch.Analysis.analysis_number=0;
        if isempty(batch.Analysis.measures),
            CONN_x.vvAnalyses.regressors.names={};
        elseif ~isstruct(batch.Analysis.measures),
            CONN_x.vvAnalyses.regressors.names=batch.Analysis.measures;
            CONN_x.vvAnalyses.regressors.measuretype=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.global=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.localsupport=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.deriv=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.filename=repmat({''},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.dimensions_in=repmat({[]},size(batch.Analysis.measures));
            CONN_x.vvAnalyses.regressors.dimensions_out=repmat({[]},size(batch.Analysis.measures));
        else
            if ~isfield(batch.Analysis.measures,'type'),batch.Analysis.measures.type=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'kernelsupport'),batch.Analysis.measures.kernelsupport=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'kernelshape'),batch.Analysis.measures.kernelshape=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'dimensions'),batch.Analysis.measures.dimensions=repmat({[]},size(batch.Analysis.measures.names)); end
            if ~isfield(batch.Analysis.measures,'dimensions_in'),batch.Analysis.measures.dimensions_in=batch.Analysis.measures.dimensions; end
            if ~isfield(batch.Analysis.measures,'dimensions_out'),batch.Analysis.measures.dimensions_out=repmat({[]},size(batch.Analysis.measures.names)); end
            CONN_x.vvAnalyses.regressors.names=batch.Analysis.measures.names;
            CONN_x.vvAnalyses.regressors.measuretype=repmat({[]},size(batch.Analysis.measures.names));
            CONN_x.vvAnalyses.regressors.global=batch.Analysis.measures.type;
            CONN_x.vvAnalyses.regressors.localsupport=batch.Analysis.measures.kernelsupport;
            CONN_x.vvAnalyses.regressors.deriv=batch.Analysis.measures.kernelshape;
            CONN_x.vvAnalyses.regressors.filename=repmat({''},size(batch.Analysis.measures.names));
            CONN_x.vvAnalyses.regressors.dimensions_in=batch.Analysis.measures.dimensions_in;
            CONN_x.vvAnalyses.regressors.dimensions_out=batch.Analysis.measures.dimensions_out;
        end
    end
    
    if isfield(batch.Analysis,'done')&&batch.Analysis.done,
        conn save;
        if ~isfield(batch.Analysis,'overwrite'), batch.Analysis.overwrite='Yes'; end
        if isscalar(batch.Analysis.overwrite)&&~isstruct(batch.Analysis.overwrite)&&ismember(double(batch.Analysis.overwrite),[1 89 121]), batch.Analysis.overwrite='Yes'; end
        CONN_x.gui=struct('overwrite',batch.Analysis.overwrite);
        if ~isfield(batch.Analysis,'analysis_number')
            conn_process('Analyses');
        else
            conn_process('Analyses',batch.Analysis.analysis_number);
        end
        CONN_x.gui=1;
        conn save;
    else
        if isfield(batch,'filename'),
            conn save;
        end
    end
end

%% RESULTS step
if isfield(batch,'Results'),
    if isfield(batch,'filename'),
        CONN_x.filename=batch.filename;
        CONN_x.gui=0;
        conn load;                      % loads existing conn_* project
        CONN_x.gui=1;
    end
    if ~isfield(batch.Results,'analysis_number')||isempty(batch.Results.analysis_number),
        if isfield(batch.Results,'between_measures'), batch.Results.analysis_number=0; 
        else batch.Results.analysis_number=1; 
        end
    end
    if batch.Results.analysis_number>0, CONN_x.Analysis=batch.Results.analysis_number; end
    if isfield(batch.Results,'foldername'),CONN_x.Results.foldername=batch.Results.foldername;else CONN_x.Results.foldername=''; end

    if isfield(batch.Results,'between_subjects')&&~isempty(batch.Results.between_subjects),
        for neffect=1:length(batch.Results.between_subjects.effect_names),
            idx=strmatch(batch.Results.between_subjects.effect_names{neffect},CONN_x.Setup.l2covariates.names,'exact');
            if isempty(idx),
                nl2covariates=length(CONN_x.Setup.l2covariates.names);
                CONN_x.Setup.l2covariates.names{nl2covariates}=batch.Results.between_subjects.effect_names{neffect};
                CONN_x.Setup.l2covariates.names{nl2covariates+1}=' ';
                for nsub=1:CONN_x.Setup.nsubjects,
                    CONN_x.Setup.l2covariates.values{nsub}{nl2covariates}=batch.Results.between_subjects.effects{neffect}(nsub);
                end
            end
        end
        CONN_x.Results.xX.nsubjecteffects=zeros(1,length(batch.Results.between_subjects.effect_names));
        for neffect=1:length(batch.Results.between_subjects.effect_names),
            idx=strmatch(batch.Results.between_subjects.effect_names{neffect},CONN_x.Setup.l2covariates.names,'exact');
            if isempty(idx), error(['unknown subject effect ',batch.Results.between_subjects.effect_names{neffect}]); return;
            else, CONN_x.Results.xX.nsubjecteffects(neffect)=idx(1); end
        end
        CONN_x.Results.xX.csubjecteffects=batch.Results.between_subjects.contrast;
        
        if ~isfield(batch.Results,'between_conditions')||isempty(batch.Results.between_conditions),
            clear batchtemp;
            if isfield(batch,'filename'), batchtemp.filename=batch.filename; else, batchtemp.filename=CONN_x.filename; end
            batchtemp.Results=batch.Results;
            for ncondition=1:length(CONN_x.Setup.conditions.names)-1,
                batchtemp.Results.between_conditions.effect_names={CONN_x.Setup.conditions.names{ncondition}};
                batchtemp.Results.between_conditions.contrast=[1];
                conn_batch(batchtemp);
            end
        else
            CONN_x.Results.xX.nconditions=zeros(1,length(batch.Results.between_conditions.effect_names));
            for neffect=1:length(batch.Results.between_conditions.effect_names),
                idx=strmatch(batch.Results.between_conditions.effect_names{neffect},CONN_x.Setup.conditions.names,'exact');
                if isempty(idx), error(['unknown condition ',batch.Results.between_conditions.effect_names{neffect}]); return;
                else, CONN_x.Results.xX.nconditions(neffect)=idx(1); end
            end
            CONN_x.Results.xX.cconditions=batch.Results.between_conditions.contrast;
            
            if isfield(batch.Results,'done')&&batch.Results.done&&batch.Results.analysis_number>0&&any(CONN_x.Analyses(CONN_x.Analysis).type==[1,3]),
                CONN_x.gui=struct('overwrite','Yes');
                conn_process('results_roi');
                CONN_x.gui=1;
                CONN_x.Results.foldername=[];
                conn save;
            end
            
            if batch.Results.analysis_number>0&&any(CONN_x.Analyses(CONN_x.Analysis).type==[2,3]) && (~isfield(batch.Results,'between_sources')||isempty(batch.Results.between_sources)),
                clear batchtemp;
                if isfield(batch,'filename'), batchtemp.filename=batch.filename; else, batchtemp.filename=CONN_x.filename; end
                batchtemp.Results=batch.Results;
                for nsource=1:length(CONN_x.Analyses(CONN_x.Analysis).sources),
                    batchtemp.Results.between_sources.effect_names={CONN_x.Analyses(CONN_x.Analysis).sources{nsource}};
                    batchtemp.Results.between_sources.contrast=[1];
                    conn_batch(batchtemp);
                end
            elseif batch.Results.analysis_number==0 && (~isfield(batch.Results,'between_measures')||isempty(batch.Results.between_measures)),
                clear batchtemp;
                if isfield(batch,'filename'), batchtemp.filename=batch.filename; else, batchtemp.filename=CONN_x.filename; end
                batchtemp.Results=batch.Results;
                for nmeasure=1:length(CONN_x.vvAnalyses.regressors.names),
                    batchtemp.Results.between_measures.effect_names={CONN_x.vvAnalyses.regressors.names{nmeasure}};
                    batchtemp.Results.between_measures.contrast=[1];
                    conn_batch(batchtemp);
                end
            elseif isfield(batch.Results,'between_sources')&&batch.Results.analysis_number>0&&any(CONN_x.Analyses(CONN_x.Analysis).type==[2,3]),
                CONN_x.Results.xX.nsources=zeros(1,length(batch.Results.between_sources.effect_names));
                for neffect=1:length(batch.Results.between_sources.effect_names),
                    idx=strmatch(batch.Results.between_sources.effect_names{neffect},CONN_x.Analyses(CONN_x.Analysis).sources,'exact');
                    if isempty(idx), error(['unknown source ',batch.Results.between_sources.effect_names{neffect}]); return;
                    else, CONN_x.Results.xX.nsources(neffect)=idx(1); end
                end
                CONN_x.Results.xX.csources=batch.Results.between_sources.contrast;
                conn save;
                
                if isfield(batch.Results,'done')&&batch.Results.done,
                    CONN_x.gui=struct('overwrite','Yes');
                    conn_process('results_voxel','dosingle','seed-to-voxel');
                    CONN_x.gui=1;
                    CONN_x.Results.foldername=[];
                    conn save;
                end
            elseif isfield(batch.Results,'between_measures')&&batch.Results.analysis_number==0
                CONN_x.Results.xX.nmeasures=zeros(1,length(batch.Results.between_measures.effect_names));
                for neffect=1:length(batch.Results.between_measures.effect_names),
                    idx=strmatch(batch.Results.between_measures.effect_names{neffect},CONN_x.vvAnalyses.regressors.names,'exact');
                    if isempty(idx), error(['unknown measure ',batch.Results.between_measures.effect_names{neffect}]); return;
                    else, CONN_x.Results.xX.nmeasures(neffect)=idx(1); end
                end
                CONN_x.Results.xX.cmeasures=batch.Results.between_measures.contrast;
                conn save;
                
                if isfield(batch.Results,'done')&&batch.Results.done,
                    CONN_x.gui=struct('overwrite','Yes');
                    conn_process('results_voxel','dosingle','voxel-to-voxel');
                    CONN_x.gui=1;
                    CONN_x.Results.foldername=[];
                    conn save;
                end
            end
        end
    end
end

end

