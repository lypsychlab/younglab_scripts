function add_acompcor_regressors(root_dir,study,subjs,runs,taskname,bidstaskname)
% adds a_comp_cor_00 as user_regressors in behavioural .mat
% will overwrite any existing user_regressor fields.
% If too many runs specified, then will just continue on after printing warning message:’No movement file for this run.’
%
% Parameters:
% - root_dir: pathname, e.g., '/home/younglw/lab'
% - study: name of the study folder 'FIRSTTHIRD'
% - subjs: cell string of subject names
% - runs: number of runs
% - taskname: name by which to identify behavioral .mats
% - bidstaskname: name by which to identify bids generated .tsv files

% sample run:
% add_acompcor_regressors('/data/younglw/lab/', 'FT_FMRIPREP', subjs, 4, 'so_localizer', 'solocalizer')
% add_acompcor_regressors('/data/younglw/lab/', 'TPS_FMRIPREP', subjs, 12, 'TPS_crn', 'tps')

%{
% quick subjs cell array creator
subjs = {}
for i = [1:21 23:27 29:30]
 subjs = [subjs, sprintf('YOU_TPS_%.02d', i)]
end
%}

addpath(genpath('/data/younglw/lab/TRAG/scripts'))
addpath(genpath('/data/younglw/lab/scripts'))  % for alek_get

cd(fullfile(root_dir,study,'behavioural'));

for s=1:length(subjs)
    disp(['Subject ' subjs{s} ':'])
    for r=1:runs
        disp(['Run ' num2str(r)])
        fname=sprintf('%s.%s.%d.mat', subjs{s},taskname,r);

        % very strange try-catch protection for inclusion/exclusion of final slash in root_dir
        try  
            tsv_dir = sprintf('%s%s/derivatives/fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end)));
        catch
            tsv_dir = sprintf('%s/%s/derivatives/fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end)));
        end
        
        tsv_pattern = sprintf('*%s_run-%.02d*confounds*.tsv', bidstaskname, r);
        mvt_file = alek_get(tsv_dir , tsv_pattern);

        try
          rp = tdfread(mvt_file);
        catch
          disp(sprintf('No movement file for run %d, skipping.', r))
          continue
        end

        % add a_comp_cor_00 as user regressor
        user_regressors(1).name = 'a_comp_cor_00';
        user_regressors(1).ons = rp.a_comp_cor_00;

        try
          save(fname,'user_regressors','-append');  % -append adds new variables to an existing file. If a variable already exists in a MAT-file, then save overwrites it with the value in the workspace.
        catch
          disp(sprintf('No corresponding behavioural file for run %d, skipping.', r))
          continue
        end
        
        clear fname user_regressors;

        disp(['Successfully processed run ' num2str(r)])

    end %end runs loop
end %end subject loop


end %end function
