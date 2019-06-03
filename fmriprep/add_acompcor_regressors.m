function add_acompcor_regressors(root_dir,study,subjs,runs,taskname,bidstaskname,varargin)
% adds a_comp_cor_00 as user_regressors to behavioural .mat
% Kevin Jiang
% Last updated: 5/28/19

% Danger: Overwrites any existing user_regressor fields.
% can be optionally called with infile parameter as first element of varargin (full path or just file name if in root_dir/study folder), which makes runs parameter irrelevant

% Parameters:
% - root_dir: pathname, e.g., '/home/younglw/lab'
% - study: name of the study folder 'FIRSTTHIRD'
% - subjs: cell string of subject names
% - runs: number of runs; if too many runs specified, will just continue  after printing warning message:’No movement file for this run.'; irrelevant if infile specified
% - taskname: name by which to identify behavioral .mats
% - bidstaskname: name by which to identify bids generated .tsv files

% Optional parameter (varargin):
% - infile: full path or file name (if in root_dir/study) of infile; runs paraemter rendered irrelevant

% sample run:
% add_acompcor_regressors('/data/younglw/lab/', 'FT_FMRIPREP', subjs, 4, 'so_localizer', 'solocalizer')
% add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 12, 'TPS_crn', 'tps')
% w/ infile runs:
% add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 12, 'TPS_crn', 'tps', '/data/younglw/lab/TPS_FMRIPREP/full_infile_TPS.csv')

%{
% quick subjs cell array creator
subjs = {}
for i = [1:21 23:27 29:30]
 subjs = [subjs, sprintf('YOU_TPS_%.02d', i)]
end

OR be smart and use makeIDs('TPS', [1:30])
%}

% addpath(genpath('/data/younglw/lab/TRAG/scripts'))
addpath(genpath('/data/younglw/lab/scripts'))  % for alek_get

cd(fullfile(root_dir,study,'behavioural'));

nVarargs = length(varargin);
runslist = [1:runs]; % default behaviour for runs

for s=1:length(subjs)
    disp(['Subject ' subjs{s} ':'])

    % handle case where infile specified (overwrites runslist)
    if nVarargs == 1 
        infile = varargin{1};
        runslist = extract_behav_runs_from_infile(root_dir, study, subjs{s}, taskname, infile)
    end 

    % runslist contains behavioural .mat file run numbers
    % index of runslist corresponds to bids run numbers
    for i=1:length(runslist)
        disp(['Bids Run ' num2str(i)])  % i == bids run
        disp(['Behavioural Run ' num2str(runslist(i))])

        % continue if NaN run
        if isnan(runslist(i))
            disp('NaN run, skipping ')
            continue
        end

        fname=sprintf('%s.%s.%d.mat', subjs{s},taskname,runslist(i));  % runslist(i) == behavioural file run

        % try-catch protection for inclusion/exclusion of final slash in root_dir
        try  
            tsv_dir = sprintf('%s%s/derivatives/fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end)));
        catch
            tsv_dir = sprintf('%s/%s/derivatives/fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end)));
        end

        % remove this and recomment above lines later
        % try  
        %     tsv_dir = sprintf('%s%s/derivatives/pre5_28_19_fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end)));
        % catch
        %     tsv_dir = sprintf('%s/%s/derivatives/pre5_28_19_fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end)));
        % end
        
        tsv_pattern = sprintf('*%s_run-%.02d*confounds*.tsv', bidstaskname, i);  % use bids run, not behavioural run
        mvt_file = alek_get(tsv_dir , tsv_pattern);

        if isempty(mvt_file)
            disp(sprintf('No movement file for bids run %d, skipping.', i))
            continue
        else
            rp = tdfread(mvt_file);
        end

        % add a_comp_cor_00 as user regressor
        user_regressors(1).name = 'a_comp_cor_00';
        user_regressors(1).ons = rp.a_comp_cor_00;

        try
            save(fname,'user_regressors','-append');  % -append adds new variables to an existing file. If a variable already exists in a MAT-file, then save overwrites it with the value in the workspace.
        catch
            disp(sprintf('No corresponding behavioural file for bids run %d, skipping.', i))
            continue
        end
        
        clear fname user_regressors;

        disp(['Successfully processed bids run ' num2str(i)])

    end %end runs loop
end %end subject loop

end %end function
