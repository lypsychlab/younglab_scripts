
addpath('/usr/public/spm/spm12');
addpath(genpath('/data/younglw/lab/scripts/'));
mfilepath = '/data/younglw/lab/TRAG/scripts';
addpath(mfilepath);

% parameters: study folder, subject name, behavioural.mat name; task name in bids, runs, ??
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_01','tom_localizer','tomlocalizer',[1 2],'no_art');

% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_03','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_04','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_05','tom_localizer','tomlocalizer',[1 2],'no_art');  % weird naming error
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_06','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_07','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_08','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_09','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_10','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_11','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_12','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_13','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_14','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_15','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_16','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_19','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_20','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_21','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_22','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_23','tom_localizer','tomlocalizer',[1 2],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('FT_FMRIPREP','YOU_FIRSTTHIRD_24','tom_localizer','tomlocalizer',[1 2],'no_art');

%TRAG 1st-level models
% EST time: ~ 35 min per model
 
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_05','TRAGfull','trag',[1 2 3 4 5 6],'no_art');  % weird naming error
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_03','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_04','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_06','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_07','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_08','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_09','TRAGfull','trag',[1 2 3 4 5 6],'no_art');  % qsub1 ends

% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_10','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_11','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_12','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_13','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_14','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_15','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_16','TRAGfull','trag',[1 2 3 4 5 6],'no_art');  % qsub2 ends

% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_19','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_20','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_21','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_22','TRAGfull','trag',[1 2 3 4 5 6],'no_art');  % error (see screenshot on desktop)
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_23','TRAGfull','trag',[1 2 3 4 5 6],'no_art');
% younglab_model_spm12_sirius_BIDS_FT('TRAG','YOU_TRAG_24','TRAGfull','trag',[1 2 3 4 5 6],'no_art');  % qsub3 ends



