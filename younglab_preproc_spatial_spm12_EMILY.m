function younglab_preproc_spatial_spm12_EMILY (varargin)
%
% This script is the primary method of spatial preprocessing for one or more subjects
% for analysis in SPM.  It can accomodate up to 3 arguments depending on
% the number of subjects and steps you wish to perform.
%
% A) At its simplest, it may be called with one argument to
% indicate 'study', for which it will make the following assumptions:
%       1) All subjects in the directory 'study' are to be processed
%       2) Subject directories are given by the identifier 'YOU'
%       3) All preprocessing steps (realign, normalize, smooth) are to be
%       performed
%       E.G. % younglab_preproc_spatial('DIS')
%
% B) second & third arguments may be given to override these assumptions:
%       - Use a string to specify a subject or different subject filter
%       E.G. % saxelab_preproc_spatial('MOR4','SAX_MOR4_01')
%       E.G. % saxelab_preproc_spatial('MOR3','KAN')
%
%       -Specify multiple subjects with a cell of strings:
%       E.G. % saxelab_preproc('MOR3',{'KAN_MOR3_07','KAN_MOR3_11'})
%
%       - Specify preprocessing steps with an integer:
%           (all preprocessing sequences are given by additive combinations
%            of the integers that represent each step)
%               1* = realign
%               2* = normalize
%               3  = realign & normalize
%               4* = smooth
%               5  = realign & smooth
%               6  = normalize & smooth
%               7  = realign, normalize, & smooth (default)
%       E.G. % saxelab_preproc_spatial('MEM',4)
%
% C) *Dealing with :  If you include the string 'pace', the script will
% process starting on the 2nd functional run and skip every other (so don't
% be an idiot like me and delete the non-pace runs, and then try to use
% 'pace'). This assumes that 'pace' takes only odd runs.

% Note that the order of the third and fourth arguments is irrelevant,
%  the code is only sensitive to the class of its inputs.
%       Examples with 3 arguments:
%       E.G. % saxelab_preproc_spatial('CogDev','4',1)
%       E.G. % saxelab_preproc_spatial('MOR4',4,'SAX_MOR4_01')
%       E.G. % saxelab_preproc_spatial('CHAR2',{'SAX_CHAR2_03','SAX_CHAR2_04',...
%       'SAX_CHAR2_07','SAX_CHAR2_09'},5)

% ============================ Usage Notes ===========================
% There is a common tweak for preprocessing that didn't deserve
% "arguement" status: 
%   
%       Which functional data to look for when running preprocessing steps
%   independently.  That is, for prep_seq values of 2, 4, or 6 we need to
%   make an assumption about whether or not realignment (and normalization)
%   have been done.  The most common reasons for this will be either matlab
%   crashes after realignment is complete, or smoothing un-normalized data 
%   for a within-subjects study.  Control of these assumptions is simply
%   achieved by toggling a boolean for the variables "realigned" &
%   "normalized" in the preprocess function (see lines ~210  and ~230).
%       -Default: smooth rrun* data for prep_seq=4, wrrun* for prep_seq>5
%
% ======================== DEVELOPMENT NOTES =========================
% check with sue about reslicing - can spm_norm recognize the rp* text file
% and incorporate those realignment parameters (or is the only way to
% normalize realigned data to perform a reslice at that step?)  -same w/
% smooth....    Consider passing OPT and perhaps others to each function
%
% -Saxelab, Jon Scholz 10/18/06
% ====================================================================
% To port this script to another workstation environment you can change the
% root directory here.  
% This script expects the following directory structure:
%       EXPERIMENT_ROOT_DIR
%               |                        
%           <experiment(s)>                     
%               |                                      
%           <subject(s)>                         
%               ^                                     
% <bold> <dicom> <3danat> <results> <scout> <roi>     
%   ^                         ^               |        
% <001...00n>             <task(s)>          ...   
spm fmri
global EXPERIMENT_ROOT_DIR;
EXPERIMENT_ROOT_DIR = '/Users/wass/Documents';

%addpath(genpath('/software/spm12'));

pace = 0;   % flag for the use of "pace" algorithm (w/in run realignment - 
%           doubles # of functional runs) - tells the script to process
%           only even functional runs
prep_seq = 7; % code for preprocessing steps
% ====================================================================

if nargin<1
    help younglab_preproc;
end

if nargin==1
    study    = varargin{1};
    subj_dir_identifier = 'YOU';
    subject = find_subjects(study,subj_dir_identifier);
    preprocess(study,subject,prep_seq,0);
end

if nargin>=2
    study    = varargin{1};
    for i=2:nargin
        switch class(varargin{i})
            case 'char'
                if strcmp(varargin{i},'pace')
                    pace = 1;
                else
                    subject = test_id(study,varargin{i});
                end

            case 'cell'
                subject = varargin{i};

            case 'double'
                prep_seq = varargin{i};
        end
    end
    preprocess(study,subject,prep_seq,pace)
end


end % Main Body

function subject = find_subjects(study,subj_dir_identifier)
% Sub-function to create an array of subject names
% takes a string identifier and churns through 'study' looking for matches

global EXPERIMENT_ROOT_DIR;
cd(fullfile(EXPERIMENT_ROOT_DIR,study));
study_dir = dir;
[study_num_dirs junk] = size(study_dir);
[dir_list{1:study_num_dirs}] = deal(study_dir.name);

x = 1;
for d=1:study_num_dirs
    is_subject = strncmpi(subj_dir_identifier,dir_list(d),length(subj_dir_identifier));
    if is_subject == 1
        subject(x) = dir_list(d);
        x = x+1;
    end
end
%now "subject" is a cell array containing all of the subject directory
%names
if ~exist('subject') % For troubleshooting
    subject=0;
end
end % function find_subjects

function subject = test_id(study,test_str)
% Sub-function to distinguish between subjID or subject_dir_identifier for varargin{2}
% if it can't find 'test_str' in 'study' it will send 'test_str' to find_subjects
global EXPERIMENT_ROOT_DIR;

if ~exist(fullfile(EXPERIMENT_ROOT_DIR,study,test_str))
    % If interpreting test_str as subjID fails, try it as an identifier
    subject = find_subjects(study,test_str);
else
    subject{1} = test_str;
end
% returns 'subject', which contains 1 or more subjects in cell format
end % function test_id

function preprocess(study,subject,prep_seq,pace)
global EXPERIMENT_ROOT_DIR;
orig_prep_seq = prep_seq;
normalised=0;
for subj_index=1:length(subject)
    % ================ To gather images for all spm steps =================
    % First gather directory for current subject
    subjID = char(subject(subj_index));
    cd(fullfile(EXPERIMENT_ROOT_DIR,study,subjID,'bold'));
    subj_dir = dir('0*');
    if exist('func_runs')
        clear func_runs
    end

    % Now filter out BS and populate a cell array of functional run
    % directories
    x=1;
    for dir_index=1:(1+pace):length(subj_dir) %if pace takes odd runs
        if subj_dir(dir_index).isdir && subj_dir(dir_index).name(1) == '0'
            func_runs{x} = subj_dir(dir_index).name;
            x=x+1;
        end
    end
    %=====================================================================
    % Now decide what the user wants done and get to it
    
    % constants (restore prep_seq in case it was changed in previous pass)
    realigned = 0; normalised = 0; prep_seq = orig_prep_seq;
    if mod(prep_seq,2)  % grabs even values of prep_seq
         % try
            func_images = get_images(study, subjID, func_runs, realigned,normalised);
            fprintf ('==============================\n');
            fprintf ('Realigning subject %s\n',subjID);
            fprintf ('==============================\n');
            realign(study,subjID,func_images);
            fprintf ('==============================\n');
            fprintf ('     Realignment complete\n');
            fprintf ('==============================\n');
            prep_seq = prep_seq-1;
            realigned = 1;
       % catch
       %     fprintf ('==========================================\n');
       %     fprintf ('Realignment failed for subject %s\n',subjID);
       %     fprintf ('==========================================\n');
       % end
    end


    if prep_seq && ~xor(prep_seq,prep_seq-4) % isolates 2 & 6 from 0 & 4
        realigned = 1;  % toggle this to control the behavior of saxelab_prep_bch
        % when prep_seq=2 or prep_seq=6. Only change this if you actually
        % want to normalize un-realigned data
         % try
            func_images = get_images(study, subjID, func_runs, realigned,normalised);
            fprintf ('==========================================\n');
            fprintf ('Normalising subject %s functionals\n',subjID);
            fprintf ('==========================================\n');
            normalise(study, subjID, func_runs, func_images,'functionals');
            fprintf ('==========================================\n');
            fprintf ('     Funtional normalisation complete\n');
            fprintf ('==========================================\n');
            normalised=1;
            prep_seq = prep_seq - 2;
        % catch
        %     fprintf ('=========================================================\n');
        %     fprintf ('Normalisation of functionals failed for subject %s\n',subjID);
        %     fprintf ('=========================================================\n');
        % % end
        try
            fprintf ('==========================================\n');
            fprintf ('Normalising subject %s anatomicals\n',subjID);
            fprintf ('==========================================\n');
            normalise(study, subjID, func_runs, func_images,'anatomical');
            fprintf ('=========================================\n');
            fprintf ('     Anatomical normalisation complete\n');
            fprintf ('=========================================\n');
        catch
            fprintf ('=========================================================\n');
            fprintf ('Normalisation of anatomical failed for subject %s\n',subjID);
            fprintf ('=========================================================\n');
        end
    end

    if prep_seq == 4 % now if a 4 remains, smooth
        realigned = 1; %normalised=1; % Default = commented
        % toggle these to control the behavior of saxelab_prep_bch
        % when prep_seq=4 (comment "normalised" to smooth rrun data for
        % prep_seq=4 and wrrun when prep_seq>=6
         try
            % set smothing kernel relative to normalization
            if normalised==1; fullwhm = 5;% 5mm full width half max
            else          fullwhm = 8;% 8mm full width half max
            end
            func_images = get_images(study, subjID, func_runs, realigned,normalised);
            fprintf ('=====================================\n');
            fprintf ('Smoothing subject %s with %dmm kernel\n',subjID,fullwhm);
            fprintf ('=====================================\n');
            smooth(study, subjID, func_images, fullwhm);
            fprintf ('==============================\n');
            fprintf ('       Smoothing complete\n');
            fprintf ('==============================\n');
            fprintf ('       Cleaning Up...\n');
            fprintf ('==============================\n');
            cd(fullfile(EXPERIMENT_ROOT_DIR,study,subjID));
            % !rm -f bold/*/wrrun*;
            % !rm -f bold/*/rrun*;
            
            boldDir = sprintf('%s/%s/%s/bold',EXPERIMENT_ROOT_DIR,study,subjID);
            cd(boldDir);

            content_boldDir = dir(boldDir);
            number_boldDir = content_boldDir(3:(end-1));

            
%             fprintf ('Deleting wraf* and raf* files for subject %s\n',subjID);
%             for dirs = 1:(length(number_boldDir)) % removing all wrarun* and rarun* files in each bold dir
%                 if ~isempty(str2num(number_boldDir(dirs).name))
%                     cd(sprintf('%s',number_boldDir(dirs).name));
% %                     delete('wraf*.img');
% %                     delete('wraf*.hdr');
% %                     delete('raf*.img');
% %                     delete('raf*.hdr');
%                 end
%                 cd(boldDir);
%                 fprintf ('%s.............Done\n',number_boldDir(dirs).name);
%             end

            
            fprintf ('       Done.\n');
            fprintf ('==============================\n');
        catch
            fprintf ('==========================================\n');
            fprintf ('Smoothing failed for subject %s\n',subjID);
            fprintf ('==========================================\n');
        end
    end
end % subject loop

end % function preprocess


function [func_images] = get_images(study, subjID, func_runs, realigned, normalised)
global EXPERIMENT_ROOT_DIR;

try
    if ~realigned && ~normalised
        % Use spm_get to grab "aruns"
        for run = 1:length(func_runs)
            func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))),'af*.img');
        end
    end

    if realigned && ~normalised
        % Use spm_get to grab "raruns"
        for run = 1:length(func_runs)
            func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))), 'raf*.img');
        end
    end

    if normalised && ~realigned
        % Use spm_get to grab "waruns"
        for run = 1:length(func_runs)
            func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))),'waf*.img');
        end
    end

    if realigned && normalised
        % Use spm_get to grab "wraruns"
        for run = 1:length(func_runs)
            func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))), 'wraf*.img');
        end
    end
catch
    fprintf ('=====================================\n');
    fprintf ('Could not grab functional runs for %s \n', subjID);
    fprintf ('Did you forget to do slice-timing correction?');
    fprintf ('=====================================\n');
end
end % function get_images

%=======================================================================
function realign(study,subjID,func_images)
global EXPERIMENT_ROOT_DIR;
%---------------------------------------------------
% User-defined parameters for this analysis
%---------------------------------------------------
opt = 3;     % 1 = Realign only
% 2 = Reslice only
% 3 = Realign & reslice

weight_image = '';  % weighting image for each subject
% (only if reference images weighted)
% (i.e., defs.estimate.weight==1)

create_all = 1;         % reslice all images 1...n
% 0 = don't reslice
% 1 = create resliced images
create_all_but_one = 0; % reslice all images 2...n
% 0 = don't reslice
% 1 = create resliced images
%NOTE: can only have one of the above two set to one:
%setting both to zero is fine, but can't do both of these at
%one
create_mean = 1;        % create mean image
% 0 = don't create mean
% 1 = create mean image
% This one doesn't interact with the two above - can be zero
% or one without regard

clear SPM;
cd(fullfile(EXPERIMENT_ROOT_DIR, study, subjID));

% make sure defaults are present in workspace
defaults = spm_defaults_lily; % uses voxel size of 3x3x3

%%% do realignment first
realign_flags = struct('quality',defaults.realign.estimate.quality,'fwhm',5,'rtm',0);
if ~isempty(weight_image)
    realign_flags.PW = deblank(weight_image(i,:));
end;

spm_realign(func_images, realign_flags);

%%% do reslicing next, if requested
if opt == 2 | opt == 3,
    reslice_flags = struct('interp',defaults.realign.write.interp,...
        'wrap',defaults.realign.write.wrap,...
        'mask',defaults.realign.write.mask);

    if create_all
        reslice_flags.which = 2;
    elseif create_all_but_one
        reslice_flags.which = 1;
    else
        reslice_flags.which = 0;
    end
    if create_mean
        reslice_flags.mean = 1;
    else
        reslice_flags.mean = 0;
    end

    spm_reslice(func_images, reslice_flags);
end;
end % function realign
%=======================================================================
function normalise(study, subjID, func_runs, func_images,task_flag)
% The addition of the anatomical normalisation and the flag were retrofit
% and pretty kludgy.  So what if it could be better orgainzed?  It works.
global EXPERIMENT_ROOT_DIR;
opt = 3;        
% 1 = determine parameters only
% 2 = write normalized only
% 3 = determine params & write

% make sure defaults are present in workspace
defaults = spm_defaults_lily;
clear SPM;
cd(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID,'bold/'));

% ====  Normalise the functionals to the EPI/T1 template ====
% Comment out the 3 lines of the option you don't want...
% Option 1: Determine parameters from 1st functional against EPI template
if strcmp(task_flag,'functionals')
    first_run = func_runs{1};
    template_file = sprintf('/Applications/spm12/toolbox/OldNorm/EPI.nii');
    funcfiles=dir(['613/' 'raf*.img']);
    func_file=funcfiles(1).name;
    func_file=fullfile(EXPERIMENT_ROOT_DIR,study,subjID,'bold','613',func_file);
    % func_file = sprintf('%s/%s/%s/bold/%s/raf0-0%s-00001-000001-01.img', EXPERIMENT_ROOT_DIR, study, subjID, first_run,first_run);
    % Option 2: Determine parameters from anatomical against T1 template
    % template_file = sprintf('%s/analysis_tools/spm/spm2/templates/T1.mnc',EXPERIMENT_ROOT_DIR);;
    % func_file = sprintf('%s/%s/%s/3danat/srun002_001.img',EXPERIMENT_ROOT_DIR,study,subjID);

    template_handle = spm_vol(template_file);
    func_handle = spm_vol(func_file);
    matname = [spm_str_manip(func_file, 'sd') '_sn.mat'];
    func_images = char(func_images);

    % Determine Normalisation Parameters
    spm_normalise(template_handle, func_handle, matname, '', '', defaults.normalise.estimate);
    % Write parameters (reslice)
    spm_write_sn(func_images, matname, defaults.normalise.write);
end %functionals block

% ==== Or Normalise the anatomical to the T1 template ====
if strcmp(task_flag,'anatomical')
    anat_file = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, '3danat'), 's*.img');
    template_file = sprintf('/Applications/spm12/toolbox/OldNorm/T1.nii');
    anat_file = anat_file(length(anat_file(:,1)),:);
    %in order to pick the final anatomical acquired

    template_handle = spm_vol(template_file);
    anat_handle = spm_vol(anat_file);
    matname = [spm_str_manip(anat_file, 'sd') '_sn.mat'];
    % Normalise anatomical
    spm_normalise(template_handle, anat_handle, matname, '', '', defaults.normalise.estimate);
    % Writing
    spm_write_sn(anat_file, matname, defaults.normalise.write);
end

end % function normalise
%=======================================================================


function smooth(study, subjID, func_images, fullwhm)
global EXPERIMENT_ROOT_DIR;

% make sure defaults are present in workspace
defaults = spm_defaults_lily;

% get handles for interactive window
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Smooth');
clear SPM;
cd (fullfile(EXPERIMENT_ROOT_DIR, study, subjID,'bold/'));
func_images = char(func_images);

% Now Smooth
% ---------------------------------------------
spm('Pointer','Watch');
spm('FigName','Smooth: working',Finter,CmdLine);
spm_progress_bar('Init',size(func_images,1),'Smoothing','Volumes Complete');

for j = 1:size(func_images, 1)
    curr = deblank(func_images(j,:));
    [path,name,ext] = fileparts(curr);
    smoothed_name = fullfile(path,['s' name ext]);
    disp(smoothed_name)
    spm_smooth(curr,smoothed_name,fullwhm);
    spm_progress_bar('Set',j);
end
spm_progress_bar('Clear');
spm('FigName','Smooth: done',Finter,CmdLine);
spm('Pointer');
end % function smooth
%=======================================================================
