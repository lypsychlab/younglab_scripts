function model_params_FB_adults_item(root_dir,study,subjs,runs,taskname,after_onset)
% creates spm_inputs, con_info, and user_regressors.
%
% Parameters:
% - root_dir: pathname, e.g., '/home/younglw/lab/'
% - study: name of the study folder
% - subj_nums: cell string of subject numbers to include (i.e. if including YOU_FB_01, type 01)
% - runs: number of runs
% - taskname: new name by which to identify behavioral .mats
% - after_onset: amount in TRs added to onset (0 if event starts at the onset of the trial; 3 if event starts 3 TRs after the onset of the trial)

addpath(fullfile(root_dir,'scripts'));
cd(fullfile(root_dir,study,'behavioural'));


bids_id={};
young_id={};

for s=1:length(subjs)
    bids_id{s} = sprintf('sub-%s',subjs{s});
    young_id{s} = sprintf('YOU_FB_%s',subjs{s});

    disp(['Subject ' subjs{s} ':'])

    for r=1:runs
        disp(['Run ' num2str(r)])
        fname=sprintf('%s.FB.%02d.mat', young_id{s}, r);
        fname_new=sprintf('%s.%s.%02d.mat', young_id{s}, taskname, r);
        f=load(fname);

        ips = f.ips;

        item_names = repmat({'coop', 'comp', 'neutral'},1,2);
        item_condnum = [1 2 3 1 2 3]; % numbers corresponding to condition
        item_num = [1 1 1 2 2 2]; % first or second trial of the same type
        onsets = [6,21,36,51,66,81] + after_onset; %pre-defined onset values

        for trial=1:length(f.cond_run) % # of trials
            spm_inputs(trial).name = sprintf('%s_%02d', item_names{trial}, item_num(trial));
            spm_inputs(trial).dur = 9 - after_onset; % in TRs; story: 10s, statement: 4s, response: 4s

            if item_num(trial) == 1
                spm_inputs(trial).ons = onsets(find(f.cond_run == item_condnum(trial), 1, 'first'));
            else
                spm_inputs(trial).ons = onsets(find(f.cond_run == item_condnum(trial), 1, 'last'));
            end

        end

        % set up con_info
        con_info(1).name  = 'coop_comp_vs_neutral';
        con_info(1).vals  = [0.5 0.5 -1 0.5 0.5 -1];
        con_info(2).name  = 'coop_vs_comp';
        con_info(2).vals  = [1 -1 0 1 -1 0];
        con_info(3).name  = 'comp_vs_coop';
        con_info(3).vals  = [-1 1 0 -1 1 0];
        con_info(4).name  = 'coop_vs_neutral';
        con_info(4).vals  = [1 0 -1 0 1 -1];
        con_info(5).name  = 'comp_vs_neutral';
        con_info(5).vals  = [0 1 -1 0 1 -1];

        % set up mvt regressors
        clear user_regressors

        try
            mvt_file = alek_get(sprintf('%s/%s/derivs/fmriprep/%s/func',root_dir,study,bids_id{s}),sprintf('%s_task-FB_run-%02d*.tsv',bids_id{s},r));
        catch
            mvt_file = alek_get(sprintf('%s/%s/derivs/fmriprep/%s/func',root_dir,study,bids_id{s}),sprintf('%s_task-FB_run-%02d*.tsv',bids_id{s},r));
        end

        rp = tdfread(mvt_file);

        user_regressors(1).name = 'mvt_x';
        user_regressors(1).ons = rp.X;
        user_regressors(2).name = 'mvt_y';
        user_regressors(2).ons = rp.Y;
        user_regressors(3).name = 'mvt_z';
        user_regressors(3).ons = rp.Z;
        user_regressors(4).name = 'mvt_pitch';
        user_regressors(4).ons = rp.RotX;
        user_regressors(5).name = 'mvt_roll';
        user_regressors(5).ons = rp.RotY;
        user_regressors(6).name = 'mvt_yaw';
        user_regressors(6).ons = rp.RotZ;

        save(fname_new, 'spm_inputs','con_info', 'user_regressors', 'ips');
        clear f fname spm_inputs con_info user_regressors;

        disp(['Successfully processed run ' num2str(r)])

    end %end runs loop
end %end subject loop

clear bids_id young_id

end %end function