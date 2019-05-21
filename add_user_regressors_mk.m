function add_user_regressors(root_dir,study,subjs,runs,taskname, run_file)
% creates spm_inputs, con_info, and user_regressors.
%
% Parameters:
% - root_dir: pathname, e.g., '/home/younglw/lab/'
% - study: name of the study folder 'FIRSTTHIRD'
% - subjs: cell string of subject names
% - runs: number of runs
% - taskname: name by which to identify behavioral .mats
% - run_file: name of file containing bold folder numbers for scanner runs of each sub. (ex, see /home/younglw/lab/FIRSTHIRD/mfiles/FIRSTTHIRD_runs_info.csv)
    %ex input: run_file = 'FIRSTTHIRD_runs_info.csv'

cd(fullfile(root_dir,study,'behavioural'));

% load csv file with run info (for mvt regressors)
filepath = fullfile(root_dir, study, 'mfiles', run_file);
fileID = fopen(filepath);
txt = textscan(fileID, '%s %s %d %d %d %d %d %d','delimiter', ',', 'headerlines', 1);
fclose(fileID); % close csv file

for s=1:length(subjs)
    disp(['Subject ' subjs{s} ':'])
    for r=1:runs
        disp(['Run ' num2str(r)])
        fname=sprintf('%s.%s.%d.mat', subjs{s},taskname,r);
        f=load(fname);

        % set up mvt regressors
        clear user_regressors

        indx = find(ismember(txt{1},subjs{s}));
        keyboard;
        boldnum = txt{2+r}(indx);
        
        try
            mvt_file = alek_get(sprintf('%s%s/%s/bold/%.3d',root_dir,study,subjs{s},boldnum),'rp_af*.txt');
        catch
            mvt_file = alek_get(sprintf('%s/%s/bold/%.3d',root_dir,study,subjs{s},boldnum),'rp_af*.txt');
        end

        rp = load(mvt_file);

        user_regressors(1).name = 'mvt_x';
        user_regressors(1).ons = rp(:,1);
        user_regressors(2).name = 'mvt_y';
        user_regressors(2).ons = rp(:,2);
        user_regressors(3).name = 'mvt_z';
        user_regressors(3).ons = rp(:,3);
        user_regressors(4).name = 'mvt_pitch';
        user_regressors(4).ons = rp(:,4);
        user_regressors(5).name = 'mvt_roll';
        user_regressors(5).ons = rp(:,5);
        user_regressors(6).name = 'mvt_yaw';
        user_regressors(6).ons = rp(:,6);

        save(fname,'user_regressors','-append');
        clear f fname user_regressors;

        disp(['Successfully processed run ' num2str(r)])

    end %end runs loop
end %end subject loop


end %end function
