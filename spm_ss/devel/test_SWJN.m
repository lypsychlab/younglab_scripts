% example script.
% This script will perform GcSS fROI analyses, using the contrast 'S-N'
% both as localizer contrast and contrast of interest (the toolbox will
% automatically break down these contrasts by sessions and perform
% cross-validation with the resulting session-specific estimates)
%

experiments(1)=struct(...
    'name','SWN',...% SWN expt 
    'pwd1','/mindhive/nklab/projects/langmus/data/',...
    'pwd2','firstlevel_SWN',...
    'data',{{'langmus_01','langmus_02','langmus_05','langmus_06','langmus_07','langmus_08','langmus_09','langmus_10'}});
experiments(2)=struct(...
    'name','langmus_subjects',...% music expt
    'pwd1','/mindhive/nklab/projects/langmus/data/',...
    'pwd2','firstlevel_music',...
    'data',{{'langmus_01','langmus_02','langmus_05','langmus_06','langmus_07','langmus_08','langmus_09','langmus_10'}});

localizer_spmfiles={};
for nsub=1:length(experiments(1).data),
    localizer_spmfiles{nsub}=fullfile(experiments(1).pwd1,experiments(1).data{nsub},experiments(1).pwd2,'SPM.mat');
end

effectofinterest_spmfiles={};
for nsub=1:length(experiments(2).data),
    effectofinterest_spmfiles{nsub}=fullfile(experiments(2).pwd1,experiments(2).data{nsub},experiments(2).pwd2,'SPM.mat');
end

ss=struct(...
    'swd','/groups/swjn/analysis/test_S-N_SWJN',...         % output directory
	'EffectOfInterest_spm',{cat(1,repmat(localizer_spmfiles,[3,1]),repmat(effectofinterest_spmfiles,[1,1]))},...
	'Localizer_spm',{cat(1,localizer_spmfiles,effectofinterest_spmfiles)},...
    'EffectOfInterest_contrasts',{{'S','W','N','M-R'}},...    % contrasts of interest
    'Localizer_contrasts',{{'S-N','M-R'}},...                     % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
    'Localizer_thr_type',{{'FDR','none'}},...
    'Localizer_thr_p',[.05,.5],...
    'type','mROI',...                                       % can be 'GcSS' (for automatically defined ROIs), 'mROI' (for manually defined ROIs), or 'voxel' (for voxel-based analyses)
    'smooth',6,...                                          % (FWHM mm)
    'ManualROIs','/groups/swjn/analysis/toolbox_SWJN_basic/test_REST-S-N_FDR05_FIRST-S-N/fROIs.img',...    
    'overlap_thr',.1,...
    'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
    'estimation','ReML',...
    'ExplicitMasking',[],...
    'ask','missing');                                       % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)
ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
ss=spm_ss_estimate(ss);





