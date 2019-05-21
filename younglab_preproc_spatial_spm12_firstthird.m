function younglab_preproc_spatial_spm12_firstthird (varargin)
% 
% see the younglab_preproc_spatial documentation for overall tips.
% 
% Changes to this file:
% - Normalization is replaced by coregistration.
% - Coregistration computes the warp of the anatomical to mean functional image, then applies the warp to all realigned functional files.
% - This brings all functional files into the same space as the anatomical image, allowing you to model without normalizing.
% - Reslicing is only performed after realignment + coregistration, so for realignment, opt = 1.

addpath(genpath('/usr/public/spm/spm12'));
spm fmri
global EXPERIMENT_ROOT_DIR;
EXPERIMENT_ROOT_DIR = '/home/younglw/lab';
addpath(genpath('/home/younglw/lab/scripts'));

pace = 0;   % flag for the use of "pace" algorithm (w/in run realignment - 
%           doubles # of functional runs) - tells the script to process
%           only even functional runs
prep_seq = 7; % code for preprocessing steps
img_type = '.nii';
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
                else if strcmp(varargin{i},'img')
                    img_type = '.img';
                else
                    subject = test_id(study,varargin{i});
                end
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
coregistered=0;
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
    realigned = 0; coregistered = 0; prep_seq = orig_prep_seq;
    if mod(prep_seq,2)  % grabs even values of prep_seq
            func_images = get_images(study, subjID, func_runs, realigned,coregistered);
            fprintf ('==============================\n');
            fprintf ('Realigning subject %s\n',subjID);
            fprintf ('==============================\n');
            realign(study,subjID,func_images);
            fprintf ('==============================\n');
            fprintf ('     Realignment complete\n');
            fprintf ('==============================\n');
            prep_seq = prep_seq-1;
            realigned = 1;

    end


    if prep_seq && ~xor(prep_seq,prep_seq-4) % isolates 2 & 6 from 0 & 4
        realigned = 1;  % toggle this to control the behavior of saxelab_prep_bch
        % when prep_seq=2 or prep_seq=6. Only change this if you actually
        % want to normalize un-realigned data
            func_images = get_images(study, subjID, func_runs, realigned,coregistered);
            fprintf ('==========================================\n');
            fprintf ('Coregistering subject %s functionals\n',subjID);
            fprintf ('==========================================\n');
            coregister(study, subjID, func_runs, func_images);
            fprintf ('==========================================\n');
            fprintf ('     Coregistration complete\n');
            fprintf ('==========================================\n');
            coregistered=1;

 
    end

    if prep_seq == 4 % now if a 4 remains, smooth
        realigned = 1; %coregistered=1; % Default = commented
        % toggle these to control the behavior of saxelab_prep_bch
        % when prep_seq=4 (comment "coregistered" to smooth rrun data for
        % prep_seq=4 and wrrun when prep_seq>=6
         try
            % set smothing kernel relative to normalization
            if coregistered==1; fullwhm = 5;% 5mm full width half max
            else          fullwhm = 8;% 8mm full width half max
            end
            func_images = get_images(study, subjID, func_runs, realigned,coregistered);
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
            
            boldDir = sprintf('%s/%s/%s/bold',EXPERIMENT_ROOT_DIR,study,subjID);
            cd(boldDir);

            content_boldDir = dir(boldDir);
            number_boldDir = content_boldDir(3:(end-1));
            
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


function [func_images] = get_images(study, subjID, func_runs, realigned, coregistered)
% func_images{n} = char array of filenames from run n
global EXPERIMENT_ROOT_DIR;
fprintf('Getting images...\n');
try
    if ~realigned && ~coregistered
        % Use spm_get to grab "aruns"
        for run = 1:length(func_runs)
            func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))),['af*' img_type]);
        end
    end

    if realigned && ~coregistered
        % Use spm_get to grab "raruns"
        for run = 1:length(func_runs)
            func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))), ['raf*' img_type]);
        end
    end
catch
    fprintf ('=====================================\n');
    fprintf ('Could not grab functional runs for %s \n', subjID);
    fprintf ('Did you forget to do slice-timing correction?');
    fprintf ('=====================================\n');
end
for rn=1:length(func_images)
    if isempty(func_images{rn})
        fprintf('You seem to be missing slice-time corrected images for run %s \n',func_runs{rn});
    end
end
end % function get_images

%=======================================================================
function realign(study,subjID,func_images)
global EXPERIMENT_ROOT_DIR;
%---------------------------------------------------
% User-defined parameters for this analysis
%---------------------------------------------------
opt = 1;     % 1 = Realign only
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
% defaults = spm_defaults_MVPA; % uses voxel size of 2x2x2
defaults=spm_defaults_lily;
%%% do realignment first
realign_flags = struct('quality',defaults.realign.estimate.quality,'fwhm',5,'rtm',0);
if ~isempty(weight_image)
    realign_flags.PW = deblank(weight_image(i,:));
end;

% keyboard;
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
    % keyboard;
    spm_reslice(func_images, reslice_flags);
end;
end % function realign
%=======================================================================

function coregister(study, subjID, func_runs, func_images)

fprintf('Running coregistration step...\n');
defaults = spm_defaults_lily;

% source_img: the anatomical file in 3danat
source_img = dir(fullfile(study,subjID,'3danat','s*.nii'));
if length(source_img) < 1
    warning('No suitable anatomical image found for coregistration.');
    break
end

source_img = fullfile(study,subjID,'3danat',source_img(1).fname);
fprintf(['Source image: ' source_img '\n']);

for r = 1:length(func_runs)
    fprintf(['Coregistering run ' num2str(r) '\n']);
    % ref_img: the mean image derived from functional realignment
    ref_img = dir(fullfile(study,subjID,'bold',func_runs{r},'mean*.nii'));
    if length(ref_img) < 1
        warning('No suitable mean image found for coregistration.\nDid you forget to realign your functionals?');
        break
    end
    ref_img = fullfile(study,subjID,'bold',func_runs{r},ref_img(1).fname);
    fprintf(['Reference image: ' ref_img '\n']);

    % % add the anatomical image as the first image for reslicing
    % % concatenate with all func images from that run
    source_imgs = cell(size(func_images,1)+1,1);
    source_imgs{1} = source_img;
    for i = 1:size(func_images{r},1)
        source_imgs{i+1} = func_images{r}(i,:);
    end

    fprintf('Running spm_coreg\n');
    % compute the coregistration matrix that results from coregistering the structural to the mean functional image
    spm_coreg(ref_img, source_img);

    % now, use the updated header to reslice the functional images
    % (i.e., resample them)
    reslice_flags = struct('interp',defaults.coreg.write.interp,...
        'mask',defaults.coreg.write.mask);
    reslice_flags.wrap = [1 1 0]; % override Lily's default; see spm_reslice.m
    reslice_flags.which = 1; % don't reslice anatomical image
    reslice_flags.mean = 0; % don't compute mean image

    fprintf('Running spm_reslice\n');
    spm_reslice(source_imgs,reslice_flags);

    % note: since realignment/coregistration both update the header matrix for the images, you only need to reslice once.

end % end run loop
end % function coregister
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