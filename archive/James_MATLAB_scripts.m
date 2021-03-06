% CONVERT DICOMS

% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_21')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_22')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_23')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_24')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_25')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_26')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_27')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_28')
% younglab_dicom_convert('HOWWHY','YOU_HOWWHY_29')


% younglab_dicom_convert_MOR4('MOR4','SAX_MOR4_06')
% younglab_dicom_convert_MOR4('MOR4','SAX_MOR4_08')


% PREPROCESS JUNK

% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_21')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_21')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_22')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_22')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_23')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_23')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_24')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_24')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_25')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_25')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_26')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_26')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_27')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_27')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_28')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_28')
% younglab_preproc_temporal('HOWWHY','YOU_HOWWHY_29')
% younglab_preproc_spatial('HOWWHY','YOU_HOWWHY_29')

% younglab_preproc_temporal_MOR4('MOR4','SAX_MOR4_05')
% younglab_preproc_spatial_MOR4('MOR4','SAX_MOR4_05')


% CONVERT ONSETS FROM SECONDS TO TRs!
% convert_TR(study,subj,tname,TR)
 
% convert_TR('HOWWHY','YOU_HOWWHY_18','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_19','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_20','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_21','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_22','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_23','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_24','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_25','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_26','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_27','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_28','HOWWHY',2)
% convert_TR('HOWWHY','YOU_HOWWHY_29','HOWWHY',2)


% LOCALIZER models

% younglab_model_spm8('HOWWHY','YOU_HOWWHY_18','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_19','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_20','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_21','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_22','tom_localizer',[21 23])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_23','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_24','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_25','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_26','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_27','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_28','tom_localizer',[19 21])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_29','tom_localizer',[21 23])
% 
%  
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_18','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_19','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_20','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_21','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_22','HOWWHY',[7 9 11 13 15 17 19 25 27 29 31 33 35 37])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_23','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_24','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_25','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_26','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_27','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_28','HOWWHY',[5 7 9 11 13 15 17 23 25 27 29 31 33 35])
% younglab_model_spm8('HOWWHY','YOU_HOWWHY_29','HOWWHY',[7 9 11 13 15 17 19 25 27 29 31 33 35 37])
%  

% younglab_model_spm8('XPECT','YOU_XPECT_04','tom_localizer',[13 15])
% younglab_model_spm8('XPECT','YOU_XPECT_05','tom_localizer',[11 13])


% OUTCOME models

% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_01','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_02','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_03','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_04','XPECT.outcome',[5 7 11 17 19])
% 
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_01','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_02','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_03','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_04','XPECT.outcome',[5 7 11 17 19])
 

% Random Effects

% younglab_RFX_spm8('XPECT','tom_localizer_results_normed',makeIDs('XPECT',[1:20]),1,'belief-photo')
% 
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:20]),1,'Stor_Non-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:20]),2,'Stor_Non-Men')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:20]),3,'Stor_Beh-Non')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:20]),4,'Stor_Beb-Men')


% CLUSTER THRESHOLD

% cluster_threshold_beta(72,72,36,3,3,8,3,'none',0,0,.05,.01,1000,'cluster_threshold')


% MOVING JUNK

% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.expect.stories_results_normed','XPECT.expect_story_results_normed_unsmoothed');
%     movefile('XPECT.expect.questions_results_normed','XPECT.expect_question_results_normed_unsmoothed');
%     movefile('XPECT.expect.outcomes_results_normed','XPECT.expect_outcome_results_normed_unsmoothed');
% end


 
