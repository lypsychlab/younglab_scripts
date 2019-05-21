function remove_user_regressors(root_dir,study,subjs,runs,taskname, bidstaskname)
% remoes user regresors from behavioural .mat files
% usually used before you want to add new user regressors (e.g., a_comp_cor_00)
%
% Parameters:
% - root_dir: pathname, e.g., '/home/younglw/lab'
% - study: name of the study folder 'FIRSTTHIRD'
% - subjs: cell string of subject names
% - runs: number of runs
% - taskname: name by which to identify behavioral .mats
% - bidstaskname: name by which to identify bids generated .tsv files

% sample run:
% remove_user_regressors('/data/younglw/lab/', 'FT_FMRIPREP', subjs, 4, 'so_localizer', 'solocalizer')

% sample run: 
% remove_user_regressors('/data/younglw/lab/', 'TRAG', subjs, 2, 'tom_localizer', 'beliefphoto')
% remove_user_regressors('/data/younglw/lab/', 'TRAG', subjs, 6, 'TRAGfull', 'trag')
%
% quick subjs cell array creator
% subjs = {}
% for i = [3:16 19:24]
%     subjs = [subjs, sprintf('YOU_TRAG_%.02d', i)]
% end

addpath(genpath('data/younglw/lab/TRAG/scripts'))
addpath(genpath('data/younglw/lab/scripts'))

cd(fullfile(root_dir,study,'behavioural'));

for s=1:length(subjs)
    disp(['Subject ' subjs{s} ':'])
    for r=1:runs
        disp(['Run ' num2str(r)])
        fname=sprintf('%s.%s.%d.mat', subjs{s},taskname,r);

        % danger subj-05 again has weird naming for .tsv file
        % protecting for inclusion/exclusion of final slash in root_dir
        try  
            mvt_file = alek_get(sprintf('%s%s/derivs/fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end))),sprintf('*%s_run-%.02d*confounds.tsv', bidstaskname, r));
        catch
            mvt_file = alek_get(sprintf('%s/%s/derivs/fmriprep/%s/func',root_dir,study,strcat('sub-',subjs{s}(end-1:end))),sprintf('*%s_run-%.02d*confounds*.tsv', bidstaskname, r));
        end

        % https://stackoverflow.com/questions/39149677/how-to-delete-a-variable-from-mat-file-in-matlab
        % Load in data as a structure, where every field corresponds to a variable
        % Then remove the field corresponding to the variable
        % protected if no user_regressors variable
        try
            tmp = rmfield(load(fname), 'user_regressors');
            save(fname, '-struct', 'tmp');
        end
        % Resave, '-struct' flag tells MATLAB to store the fields as distinct variables
       

        % try
        %   rp = load(mvt_file);
        % catch
        %   disp(['No movement file for this run.'])
        %   continue
        % end

        % user_regressors(1).name = 'mvt_x';
        % user_regressors(1).ons = rp(:,1);
        % user_regressors(2).name = 'mvt_y';
        % user_regressors(2).ons = rp(:,2);
        % user_regressors(3).name = 'mvt_z';
        % user_regressors(3).ons = rp(:,3);
        % user_regressors(4).name = 'mvt_pitch';
        % user_regressors(4).ons = rp(:,4);
        % user_regressors(5).name = 'mvt_roll';
        % user_regressors(5).ons = rp(:,5);
        % user_regressors(6).name = 'mvt_yaw';
        % user_regressors(6).ons = rp(:,6);

        % save(fname,'user_regressors','-append');
        % clear f fname user_regressors;

        disp(['Successfully processed run ' num2str(r)])

    end %end runs loop
end %end subject loop


end %end function
