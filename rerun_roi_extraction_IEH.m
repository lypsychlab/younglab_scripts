

dmpfc_nums=[5 7 8 13 14 16:22];
rtpj_nums=[4:8 11:14 16:22 24 25];
ltpj_nums=[4 5 7 8 11:14 16:22 24 25];
lsts_nums=[5 12 13 16 17 19:22];
mpfc_nums=[5 6 11 13 17 18 19 21 22];
pc_nums=[4 5 7 11:14 16:22 24 25];
rsts_nums=[5:8 11:14 16 17 19:22 24];
mtl_nums=rtpj_nums;

subjs={};

%change this to run different rois:
for snum=1:length(mtl_nums)
    subjs{end+1}=sprintf(['1' '%02d'], mtl_nums(snum));
end

%DMPFC
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'DMPFC','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');


% %RTPJ
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'RTPJ','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');
% 
% %LTPJ
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'LTPJ','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');

% %LSTS
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'LSTS','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');

% %MPFC
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'MMPFC','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');

% %PC
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'PC','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');

% %RSTS
% roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
% 'RSTS','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');

% MTL subsystem ROIs
roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,...
'GROUP','ieh_resultsNEW_autocon_normed','tom_localizer_results_normed','1', 60, 6, 0, '0:60');
