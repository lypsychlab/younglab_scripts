% example script.
% This script will perform manually-defined fROI analyses, using the contrast 'REST_S-N'
% as localizer and 'FIRST_S-N' as contrast of interest, and the file
% 'ps6ffspmT_0001.img' as ROI-defining volume.
%

experiments=struct(...
    'name','SWJN_SWJN_and_SWJNV2',...% SWJN subjects, SWJNV2 subjects
    'pwd1','/groups/swjn/data/',...
    'pwd2','firstlevel_SWJNno',...
    'data',{{'SWJN_01','SWJN_05', 'SWJN_07', 'SWJN_09', 'SWJN_10', 'SWJN_11', 'SWJN_12','SWJN_13', 'SWJN_101', 'SWJN_102', 'SWJN_104', 'SWJN_105',...
    'SWJNV2_01', 'SWJNV2_02', 'SWJNV2_03', 'SWJNV2_04', 'SWJNV2_05', 'SWJNV2_06','SWJNV2_07', 'SWJNV2_08', 'SWJNV2_09', 'SWJNV2_10', 'SWJNV2_12', 'SWJNV2_13','SWJNV2_15'}});

spmfiles={};
for nsub=1:length(experiments.data),
    spmfiles{nsub}=fullfile(experiments.pwd1,experiments.data{nsub},experiments.pwd2,'SPM.mat');
end

ss=struct(...
    'swd',fullfile(pwd,'test_back'),...                          % output directory
    'files_spm',{spmfiles},...                              % first-level SPM.mat files
    'EffectOfInterest_contrasts',{{'FIRST_S-N'}},...              % contrast of interest
    'Localizer_contrasts',{{'REST_S-N'}},...                     % localizer contrast (note: if these contrasts are not orthogonal the toolbox will automatically partition theses contrasts by sessions and perform cross-validation) 
    'type','mROI',...                                       % can be 'GcSS' (for automatically defined ROIs), 'mROI' (for manually defined ROIs), or 'voxel' (for voxel-based analyses)
    'ManualROIs','/groups/swjn/data/secondlevel_SWJN_SWJN_and_SWJNV2/REST_S-N/ps6ffspmT_0001.img',...
    'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
    'ask','none');                                          % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)
ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
ss=spm_ss_estimate(ss);





