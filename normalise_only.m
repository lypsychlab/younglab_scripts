function normalise_only(study, subjID, func_runs, func_images,task_flag)
% The addition of the anatomical normalisation and the flag were retrofit
% and pretty kludgy.  So what if it could be better orgainzed?  It works.
EXPERIMENT_ROOT_DIR='/home/younglw/lab';
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
    template_file = sprintf('/usr/public/spm/spm8/templates/EPI.nii');
    func_file = sprintf('%s/%s/%s/bold/%s/raf0-0%s-00001-000001-01.img', EXPERIMENT_ROOT_DIR, study, subjID, first_run,first_run);
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
    anat_file = alek_get(fullfile(EXPERIMENT_ROOT_DIR,  study, subjID, '3danat'), 's0*.nii');
    template_file = sprintf('/usr/public/spm/spm8/templates/T1.nii');
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