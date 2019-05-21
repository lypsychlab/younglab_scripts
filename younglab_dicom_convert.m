function younglab_dicom_convert (varargin)
%
% This batch script converts dicom files and moves the resultant NIFTI
% image pairs (.hdr, .img) into the appropriate directory structures
%
% At its simplest, this script takes 1 argument (study), and makes the
% following assumptions:
% 1) All subjects in the folder '<EXPERIMENT_ROOT_DIR>/study' need to be
% converted and subjects are given by the identifier 'YOU'
% 2) The localizer scan was the first run
% 3) The AAScout scan was the second run
% 4) The MPRAGE scan was the third run
% 5) The MEMPRAGE scan was the fourth run
% The script will look for dicoms in the 'dicom' folder.
%
% A second argument can be given to specify the identifier.  You can
% 1) specify the subjID of one subject (e.g., 'SAX_DIS_08')
% 2) specify the subjIDs of several subjects in cell format (e.g.,
% {'SAX_DIS_05','SAX_DIS_06','SAX_DIS_07'})
% 3) provide a filter (e.g., 'SAX' instead of 'SAX_DIS_08'). In the event
% that the directory '<EXPERIMENT_ROOT_DIR>/study/2ndarg/dicom' doesn't
% exist, younglab_dicom_convert will default to using vargargin{2} (the 2nd
% input argument) as an identifier.  The filter (e.g., 'SAX') will also
% override the default identifier 'YOU'.
% 
% Other optional arguments include 
% 1) 'pace', which skips motion-corrected runs (default)
% 2) 'nopace', which keeps motion-corrected runs
%
% -------------------------------------------------------------------------
%
% Examples:
%
% younglab_dicom_convert('CHAR2')
%
% younglab_dicom_convert('CHAR2','SAX_CHAR2_09')
% younglab_dicom_convert('CHAR2',{'SAX_CHAR2_09','SAX_CHAR2_10'})
% younglab_dicom_convert('CHAR2','SAX')
%
% younglab_dicom_convert('CHAR2',{'SAX_CHAR2_07','SAX_CHAR2_09'},'pace')
%
% -------------------------------------------------------------------------
%
% The converted image pairs (.hdr, .img) from the localizer and AAScout
% scans will be moved into the 'scout' directory and the image pair from the 
% MPRAGE scan will be moved into the '3danat' directory. The remaining runs
% will be moved into the 'bold' directory
%
%
% by Jonathan Scholz on 9/25/06
% edited by Lily Tsoi on 10/03/11
%
% ====================================================================
% To port this script to another workstation environment you can change the
% root directory here.  
% This script expects the following directory structure:
%                        EXPERIMENT_ROOT_DIR 
%                       /                        
%           <experiment(s)>                  
%               |                                       
%           <subject(s)>                              
%               ^                                    
% <bold> <dicom> <3danat> <results> <scout> <roi>     
%   ^                         ^               |         
% <001...00n>             <task(s)>          ...       
%
%
%
%                         
%                          SOFTWARE_ROOT_DIR 
%                                 |
%                             <software>
%                            /    |   \
%                      <matlab> <spm> <fsl>
%                                 |
%                                ...


global EXPERIMENT_ROOT_DIR;
%EXPERIMENT_ROOT_DIR = getenv('EXPERIMENT_ROOT_DIR');
EXPERIMENT_ROOT_DIR = '/home/younglw/lab';

addpath(genpath('/usr/public/spm/spm8'));

pace = 0;
% ====================================================================

if nargin==0
    help younglab_dicom_convert;
    return % dont' clock it
end

study=varargin{1};

if nargin==1
    subj_dir_identifier='YOU';
    subject = find_subjects(study,subj_dir_identifier);
end

if nargin>=2
    for arg=2:nargin
        switch class(varargin{arg}) % This will test for subjID vs. identifier or string first
            case 'char' 
                % string
                if strcmp(varargin{arg},'pace')
                    pace = 1;
                    continue
                elseif strcmp(varargin{arg},'nopace');
                    pace = 0;
                    continueyoung
                end
                if ~exist(fullfile(EXPERIMENT_ROOT_DIR,study,varargin{arg}),'dir') % identifier
                    subj_dir_identifier=varargin{arg};
                    subject = find_subjects(study,subj_dir_identifier);
                    continue
                else % single subjID
                    subject{1} = varargin{arg};
                    continue
                end
                
            case 'cell' % containing subjects
                if ischar(varargin{arg}{1}) %use for subject if a string is found
                    subject=varargin{arg};
                end
        end
    end

end

tic; % start counter
convert(study, subject,pace);
dcm_time_el = toc;  % end counter
fprintf('Conversion completed in %d minutes and %.1f seconds\n',floor(dcm_time_el/60),mod(dcm_time_el,60));

end % main body

% Sub-function to create an array of subject names
function subject = find_subjects(study,subj_dir_identifier)

global EXPERIMENT_ROOT_DIR;
cd(fullfile(EXPERIMENT_ROOT_DIR,study));

study_dir = dir([subj_dir_identifier '*']);
[study_num_dirs junk] = size(study_dir);
[subject{1:study_num_dirs}] = deal(study_dir.name);

% now "subject" is a cell array containing all of the subject directory
% names
end % function find_subjects


function convert(study, subject,pace)

global EXPERIMENT_ROOT_DIR;

% sub-function - converts & moves files
[junk num_subs] = size(subject);
for subj_index=1:num_subs
    subj_as_str = char(subject(subj_index));
    subj_dir=fullfile(EXPERIMENT_ROOT_DIR,study,subj_as_str);
    
    % move all dicoms in different directories to one directory called
    % 'dicom'
    
    cd(subj_dir);
%     delete('*')
    dirname = dir('*_*');

    for i=1:length(dirname)
        movefile([dirname(i).name '/' '*'], 'dicom');
        rmdir(dirname(i).name)
    end
    
    dicom_dir=strcat(subj_dir,'/dicom');
    
    % create unpacking log
    unpack_dir = [subj_dir '/unpack'];
    summary = [unpack_dir '/summary.log'];
    unix(sprintf(['unpacksdcmdir -src ', dicom_dir, ' -targ ', unpack_dir, ' -scanonly ', summary]))
    
    cd(dicom_dir);

    % We'll need these later ons
    results_dir = fullfile(subj_dir,'results');
    roi_dir = fullfile(subj_dir,'roi');
    mkdir(results_dir); mkdir(roi_dir);
        
    fprintf ('Converting dicoms for subject %s\n',subj_as_str);
    
    dicoms = alek_get(dicom_dir,'*.IMA'); % our scanner uses this format
    if isempty(dicoms)
        dicoms = alek_get(dicom_dir,'*.dcm'); % old data format
    end
    fprintf ('dicoms read as %s\n',dicoms(1,:));
    
    hdrs = spm_dicom_headers(dicoms);
    
    if pace
        % check hdrs for func runs and grab non-motion-corrected ones
        trimmed_hdrs = struct([]);
        for dcm = 1:length(hdrs)
            isfuncrun = strcmp(hdrs{dcm}.ScanningSequence,'EP'); 
            if (~isfuncrun) || (strcmp(hdrs{dcm}.ScanningSequence,'EP') & ~strcmp(hdrs{dcm}.SeriesDescription,'MoCoSeries')) % should be more resilient, it will *never* collect MoCoSeries. 
                trimmed_hdrs{end+1} = hdrs{dcm};
            end
        end
        hdrs = trimmed_hdrs;
    end
    
    % some labs don't put '0' for patient id
    for dumb=1:length(hdrs)
        hdrs{dumb}.PatientID='0';
    end
    
    fprintf ('Converting images for subject %s\n',subj_as_str);
    spm_dicom_convert(hdrs,'all');
    
    fprintf ('Relocating MPRAGE images for subject %s\n',subj_as_str);
    anatdir = fullfile(EXPERIMENT_ROOT_DIR,study,subj_as_str,'3danat'); mkdir(anatdir);
    delete([anatdir '/*']);
    sfiles = dir([dicom_dir '/s0-0004*img']);
%     sfiles = dir([dicom_dir '/s*img']);
    for i=1:length(sfiles);temp=dir(fullfile(dicom_dir,sfiles(i).name));sizefiles(i)=temp.bytes;end
    [val, loc] = max(sizefiles); % this was used in saxelab, which picks out MPRAGE (3rd run)
    movefile(fullfile(dicom_dir,[sfiles(loc).name(1:end-3) '*']),anatdir);
%     movefile(fullfile(dicom_dir,[sfiles.name(1:end-3) '*']),anatdir);
    fprintf ('Relocating localizer images for subject %s\n',subj_as_str);
    scoutdir = fullfile(EXPERIMENT_ROOT_DIR,study,subj_as_str,'scout'); mkdir(scoutdir);
        delete([scoutdir '/*']);
    movefile([dicom_dir '/s*'],scoutdir);
    
    fprintf ('Relocating functional images for subject %s\n',subj_as_str);
    boldir = fullfile(EXPERIMENT_ROOT_DIR,study,subj_as_str,'bold'); mkdir(boldir);
    delete([boldir '/*']);
    bold_acqs = dir([dicom_dir '/f*']);
    run_num   = cell(length(bold_acqs),1);
    for i=1:length(bold_acqs)
        run_num{i}  = bold_acqs(i).name(5:7);
    end
    runs    = unique(run_num);
    run_dir = cell(length(runs),1);
    
    for i=1:length(runs)
        run_dir{i}  = [boldir '/' runs{i}]; mkdir(run_dir{i});
        movefile([dicom_dir '/f0-0' runs{i} '*'],run_dir{i});
    end
    
end % subject loop
end % function convert
