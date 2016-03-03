function younglab_copy_contrasts(study, source_subjID, results_dir, target_subjIDs,varargin)
% function copy_contrasts(study, source_subjID, results_dir, target_subjIDs, [target_results_dir/contrast/clobber])
% The script allows you to copy all contrast definitions from a source
% subject to any number of targets.
% "target_subjIDs" can be a string or a cell array of strings
% E.G. copy_contrasts('CUES','SAX_CUES_01','cues_results','SAX_CUES_02')
% E.G. copy_contrasts('CUES','SAX_CUES_01','cues_results',{'SAX_CUES_03','SAX_CUES_04'})
% In addition, you may add additional arguments to specify any of the following :
%   a) A different results directory for the target subjects (useful when 
%   doing both normalised and unnormalised analyses, for example)
%   E.G. saxelab_copy_contrasts('CUES','SAX_CUES_01','cues_results','SAX_CUES_02',
%   'cues_results_normed')
%   b) The specific contrast(s) you wish to copy, by number (don't forget 
%   that effects of interest is always 1, and is not copied by default, so 
%   the first contrast is 2)
%   c) A "clobber" bit to determine the treatment of pre-existing contrasts
%       -The default action is "append"
%       -type "clobber" to delete all extant contrasts and start from
%       scratch
%       -type "insert" to selectively replace contrasts by number
%       
%   E.G. saxelab_copy_contrasts('CUES','SAX_CUES_01','cues_results','SAX_CUES_02',
%   [4 5 6],'clobber')
%       -This would copy subj01 contrasts 4:6 to subj02 2:4
%
% E.G. saxelab_copy_contrasts('CUES','SAX_CUES_01','fb_results_normed',makeIDs('CUES',[2:15 17 18 20:23]),[3 4])

if ~nargin
    help saxelab_copy_contrasts;
    return
end

if class(target_subjIDs) == 'char'
    target_subjIDs = {target_subjIDs};
end

fprintf('Copying contrast information from subject %s across %d subjects...\n',source_subjID,length(target_subjIDs));
%first make sure target_subjIDs is in cell format
%% Collect Source data
EXPERIMENT_ROOT_DIR = getenv('EXPERIMENT_ROOT_DIR'); % /mnt/aaf on qixa, /software/saxelab on mindhive
EXPERIMENT_ROOT_DIR = '/mindhive/saxelab';
studyroot = fullfile(EXPERIMENT_ROOT_DIR,study);
sourceroot = fullfile(studyroot,source_subjID,'results',results_dir);
cd(sourceroot);
load SPM;


%This is the placeholder for our source subject data
srcspm = SPM.xCon;

%numconds     = length(SPM.Sess(1).Fc);
num_src_runs = length(SPM.nscan);
numconds     = (length(srcspm(1).c)-num_src_runs)/num_src_runs;

%specify default contrasts to copy: all except effects of interest
con_numbers = 1:length(SPM.xCon); % just an array of contrasts to copy - may be overridden by varargin
clear SPM;

%% Now adjust defaults with varargin
%   Can have any of the following: target_results_dir, scr_contrasts,
%   clobber_bit
clobber_bit = 1;
for i=1:length(varargin)
    if isstr(varargin{i})
        if strmatch(varargin{i},'clobber')
            clobber_bit=2;
        elseif strmatch(varargin{i},'insert')
            clobber_bit=3;
        else
        results_dir = varargin{i};
        end
    end
    if isfloat(varargin{i})
        con_numbers = varargin{i};
    end
end

fprintf('...copying contrast numbers [%s] from source subject\n',num2str(con_numbers));
fprintf('...to %s in target subject directories\n\n',results_dir);

%% Now insert the appropriate elements of the source SPM.xCon into the
% target mat files, then fill out data-specific elements with spm_FcUtil
% and spm_contrats
verb_str = {'Append','Clobber','Insert'};    %For informing user of selected action
action_str = {'end+1','end+1','contrast'};  %For placing sourced contrasts in the appropriate spot based on clobber_bit
% - "end+1" appends (default), "contrast" inserts into extant
% contrasts (overwriting - to preserve numbering for RFX)
for subj=1:length(target_subjIDs)
    fprintf('%sing contrasts on subject %s\n',verb_str{clobber_bit},target_subjIDs{subj});
    cd(fullfile(studyroot,target_subjIDs{subj},'results',results_dir));
    load SPM;
    num_runs = length(SPM.nscan);
    diff = num_runs - num_src_runs;
    con_loop=1;
    for contrast = con_numbers
        con_vals{contrast} = [srcspm(contrast).c(1:(numconds*min(num_src_runs,num_runs)))' srcspm(contrast).c(1:(numconds*diff))' zeros(1,num_runs)];
        con_name           = srcspm(contrast).name;
        if con_loop ==1 && clobber_bit==2
            con_cmd            = sprintf('SPM.xCon = spm_FcUtil(''Set'', con_name, ''T'', ''c'', (con_vals{contrast})'',SPM.xX.xKXs);');
            con_loop=0;
        else
            con_cmd            = sprintf('SPM.xCon(%s) = spm_FcUtil(''Set'', con_name, ''T'', ''c'', (con_vals{contrast})'',SPM.xX.xKXs);',action_str{clobber_bit});
        end
        eval(con_cmd);
    end

    % Evaluate contrasts
    %---------------------------------------------------------------------------
    spm_contrasts(SPM);
    regenCons();

end

end %main function copy_contrasts