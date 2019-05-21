function younglab_preproc_temporal (varargin)
%
% This script is the primary method of temporal preprocessing (i.e., slice time correction) for one or more subjects
% for analysis in SPM.  It can accomodate up to 3 arguments depending on
% the number of subjects and steps you wish to perform.
%
% A) At its simplest, it may be called with one argument to
% indicate 'study', for which it will make the following assumptions:
%       1) All subjects in the directory 'study' are to be processed
%       2) Subject directories are given by the identifier 'YOU'
%       3) All preprocessing steps (slice timing correction, realign, normalize, smooth) are to be
%       performed
%       E.G. % younglab_preproc('DIS')
%
% B) second & third arguments may be given to override these assumptions:
%       - Use a string to specify a subject or different subject filter
%       E.G. % saxelab_preproc('MOR4','SAX_MOR4_01')
%       E.G. % saxelab_preproc('MOR3','KAN')
%
%       -Specify multiple subjects with a cell of strings:
%       E.G. % saxelab_preproc('MOR3',{'KAN_MOR3_07','KAN_MOR3_11'})
%
% C) *Dealing with :  If you include the string 'pace', the script will
% process starting on the 2nd functional run and skip every other (so don't
% be an idiot like me and delete the non-pace runs, and then try to use
% 'pace'). 'pace' also assumes odd runs.

% Note that the order of the third and fourth arguments is irrelevant,
%  the code is only sensitive to the class of its inputs.
%       Examples with 3 arguments:
%       E.G. % saxelab_preproc('CogDev','4',1)
%       E.G. % saxelab_preproc('MOR4',4,'SAX_MOR4_01')
%       E.G. % saxelab_preproc('CHAR2',{'SAX_CHAR2_03','SAX_CHAR2_04',...
%       'SAX_CHAR2_07','SAX_CHAR2_09'},5)
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
%         EXPERIMENT_ROOT_DIR
%               |                        
%           <experiment(s)>                     
%               |                                       
%           <subject(s)>                              
%               ^                                       
% <bold> <dicom> <3danat> <results> <scout> <roi>     
%   ^                         ^               |         
% <001...00n>             <task(s)>          ...      

global EXPERIMENT_ROOT_DIR;
EXPERIMENT_ROOT_DIR = '/home/younglw/lab';

addpath(genpath('/usr/public/spm/spm8'));

pace = 0;   % flag for the use of "pace" algorithm (w/in run realignment - 
%           doubles # of functional runs) - tells the script to process
%           only even functional runs
% ====================================================================

if nargin<1
    help younglab_preproc;
end

if nargin==1
    study    = varargin{1};
    subj_dir_identifier = 'YOU';
    subject = find_subjects(study,subj_dir_identifier);
    preprocess(study,subject,0);
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
        end
    end
    preprocess(study,subject,pace)
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

function preprocess(study,subject,pace)
global EXPERIMENT_ROOT_DIR;

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
    
    try
        func_images = get_images(study, subjID, func_runs);
        fprintf ('===============================\n');
        fprintf ('Slice-timing correcting subject %s\n',subjID);
        fprintf ('===============================\n');
        slicetiming(study,subjID,func_images);
        fprintf ('=====================================\n');
        fprintf ('     Slice timing correction complete\n');
        fprintf ('=====================================\n');
    catch
       fprintf ('==========================================\n');
       fprintf ('Slice timing correction failed for subject %s\n',subjID);
       fprintf ('==========================================\n');
    end
end % subject loop

end % function preprocess


function [func_images] = get_images(study, subjID, func_runs)
global EXPERIMENT_ROOT_DIR;

    for run=1:length(func_runs)
        func_images{run} = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, 'bold', char(func_runs(run))),'f*.img');
    end

end % function get_images

%=======================================================================
function slicetiming(study,subjID,func_images)
global EXPERIMENT_ROOT_DIR;
%---------------------------------------------------
% User-defined parameters for this analysis
%---------------------------------------------------


clear SPM;
cd(fullfile(EXPERIMENT_ROOT_DIR, study, subjID));

% make sure defaults are present in workspace
defaults = spm_defaults_lily;

num_slices = 36;            % number of slices;
ref_slice = 1;              % reference slice
TR = 2;                     % TR in seconds
TA = TR-(TR/num_slices);    % TA in seconds
timing(1) = TA / (num_slices - 1);
timing(2) = TR - TA;
slice_ord = [2:2:num_slices 1:2:num_slices]; % interleaved starting even slices (b/c num_slice is even)

spm_slice_timing(func_images, slice_ord, ref_slice, [timing(1) timing(2)])

end % function slicetiming