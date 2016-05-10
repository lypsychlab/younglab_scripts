% % CONVERT DICOMS
% 
% younglab_dicom_convert('XPECT','YOU_XPECT_21')
% younglab_dicom_convert('XPECT','YOU_XPECT_22')
% younglab_dicom_convert('XPECT','YOU_XPECT_23')
% younglab_dicom_convert('XPECT','YOU_XPECT_24')
% 
% % PREPROCESS JUNK
% 
% % younglab_preproc_spatial('XPECT')
% 
% younglab_preproc_temporal('XPECT','YOU_XPECT_21')
% younglab_preproc_spatial('XPECT','YOU_XPECT_21')
% younglab_preproc_temporal('XPECT','YOU_XPECT_22')
% younglab_preproc_spatial('XPECT','YOU_XPECT_22')
% younglab_preproc_temporal('XPECT','YOU_XPECT_23')
% younglab_preproc_spatial('XPECT','YOU_XPECT_23')
% younglab_preproc_temporal('XPECT','YOU_XPECT_24')
% younglab_preproc_spatial('XPECT','YOU_XPECT_24')


% MOVING JUNK

% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.expect.stories_results_normed','XPECT.expect_story_results_normed_unsmoothed');
%     movefile('XPECT.expect.questions_results_normed','XPECT.expect_question_results_normed_unsmoothed');
%     movefile('XPECT.expect.outcomes_results_normed','XPECT.expect_outcome_results_normed_unsmoothed');
% end


% LOCALIZER models

% younglab_model_spm8('XPECT','YOU_XPECT_01','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_02','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_03','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_04','tom_localizer',[13 15])
% younglab_model_spm8('XPECT','YOU_XPECT_05','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_06','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_07','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_08','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_09','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_10','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_11','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_12','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_13','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_14','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_15','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_16','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_17','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_18','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_19','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_20','tom_localizer',[11 13])





%%%% NEW ANALYSES FOR LAST 4 SUBJECTS!!!!

% younglab_model_spm8('XPECT','YOU_XPECT_21','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_22','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_23','tom_localizer',[11 13])
% younglab_model_spm8('XPECT','YOU_XPECT_24','tom_localizer',[11 13])
% 
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_21','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_22','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_23','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_24','XPECT.outcome',[5 7 9 15 17])
% 
% names = makeIDs('XPECT',[21:24]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.outcome_results_normed','XPECT.outcome_results_normed_unsmoothed');
% end 
% 
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_21','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_22','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_23','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_24','XPECT.outcome',[5 7 9 15 17])

% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_21','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_22','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_23','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_24','XPECT.expect.outcomes',[5 7 9 15 17])
% 
% names = makeIDs('XPECT',[21:24]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.expect.outcomes_results_normed','XPECT.expect_outcome_results_normed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_21','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_22','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_23','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_24','XPECT.design.stories',[5 7 9 15 17])

% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_21','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_22','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_23','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_24','XPECT.design.outcomes',[5 7 9 15 17])


% names = makeIDs('XPECT',[21:24]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.design.stories_results_normed','XPECT.design_story_results_normed_unsmoothed');
%     %movefile('XPECT.design.outcomes_results_normed','XPECT.design_outcome_results_normed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_21','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_22','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_23','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_24','XPECT.design.stories',[5 7 9 15 17])

% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_21','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_22','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_23','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_24','XPECT.design.outcomes',[5 7 9 15 17])


%  younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_21','XPECT.expect.outcomes',[5 7 9 15 17])
%  younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_22','XPECT.expect.outcomes',[5 7 9 15 17])
%  younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_23','XPECT.expect.outcomes',[5 7 9 15 17])
%  younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_24','XPECT.expect.outcomes',[5 7 9 15 17])

 
% younglab_RFX_spm8('XPECT','XPECT.expect.outcomes_results_normed',makeIDs('XPECT',[1:24]),1,'Out_Exp-Unexp')
% younglab_RFX_spm8('XPECT','XPECT.expect.outcomes_results_normed',makeIDs('XPECT',[1:24]),2,'Out_Unexp-Exp') 
%  
 
%%%% END NEW ANALYSES!!!!!!!!!!






% OUTCOME models

% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_01','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_02','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_03','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_04','XPECT.outcome',[5 7 11 17 19])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_05','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_06','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_07','XPECT.outcome',[5 7 9 17 19])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_08','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_09','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_10','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_11','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_12','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_13','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_14','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_15','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_16','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_17','XPECT.outcome',[5 7 9 15 19])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_18','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_19','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_20','XPECT.outcome',[5 7 9 15 17])
% 
% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.outcome_results_normed','XPECT.outcome_results_normed_unsmoothed');
% end 
% 
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_01','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_02','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_03','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_04','XPECT.outcome',[5 7 11 17 19],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_05','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_06','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_07','XPECT.outcome',[5 7 9 17 19],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_08','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_09','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_10','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_11','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_12','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_13','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_14','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_15','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_16','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_17','XPECT.outcome',[5 7 9 15 19],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_18','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_19','XPECT.outcome',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_unsmoothed('XPECT','YOU_XPECT_20','XPECT.outcome',[5 7 9 15 17],'unnormed')
% 
% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.outcome_results_unnormed','XPECT.outcome_results_unnormed_unsmoothed');
% end 
% 
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_01','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_02','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_03','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_04','XPECT.outcome',[5 7 11 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_05','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_06','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_07','XPECT.outcome',[5 7 9 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_08','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_09','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_10','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_11','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_12','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_13','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_14','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_15','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_16','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_17','XPECT.outcome',[5 7 9 15 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_18','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_19','XPECT.outcome',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_20','XPECT.outcome',[5 7 9 15 17])




% % EXPECT models
% 
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_01','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_02','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_03','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_04','XPECT.expect.outcomes',[5 7 11 17 19])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_05','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_06','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_07','XPECT.expect.outcomes',[5 7 9 17 19])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_08','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_09','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_10','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_11','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_12','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_13','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_14','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_15','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_16','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_17','XPECT.expect.outcomes',[5 7 9 15 19])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_18','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_19','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_20','XPECT.expect.outcomes',[5 7 9 15 17])
% 
% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.expect.stories_results_normed','XPECT.expect_story_results_normed_unsmoothed');
%     movefile('XPECT.expect.questions_results_normed','XPECT.expect_question_results_normed_unsmoothed');
%     movefile('XPECT.expect.outcomes_results_normed','XPECT.expect_outcome_results_normed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_01','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_02','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_03','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_04','XPECT.expect.outcomes',[5 7 11 17 19],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_05','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_06','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_07','XPECT.expect.outcomes',[5 7 9 17 19],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_08','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_09','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_10','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_11','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_12','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_13','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_14','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_15','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_16','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_17','XPECT.expect.outcomes',[5 7 9 15 19],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_18','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_19','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_E_unsmoothed('XPECT','YOU_XPECT_20','XPECT.expect.outcomes',[5 7 9 15 17],'unnormed')
% 
% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.expect.stories_results_unnormed','XPECT.expect_story_results_unnormed_unsmoothed');
%     movefile('XPECT.expect.questions_results_unnormed','XPECT.expect_question_results_unnormed_unsmoothed');
%     movefile('XPECT.expect.outcomes_results_unnormed','XPECT.expect_outcome_results_unnormed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_01','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_02','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_03','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_04','XPECT.expect.outcomes',[5 7 11 17 19])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_05','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_06','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_07','XPECT.expect.outcomes',[5 7 9 17 19])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_08','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_09','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_10','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_11','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_12','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_13','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_14','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_15','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_16','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_17','XPECT.expect.outcomes',[5 7 9 15 19])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_18','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_19','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_E('XPECT','YOU_XPECT_20','XPECT.expect.outcomes',[5 7 9 15 17])

 
% % DESIGN models
% 
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.outcomes',[5 7 11 17 19])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.outcomes',[5 7 9 17 19])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_12','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.outcomes',[5 7 9 15 19])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.outcomes',[5 7 9 15 17])
% 
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.stories',[5 7 11 17 19])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.stories',[5 7 9 17 19])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_12','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.stories',[5 7 9 15 19])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.stories',[5 7 9 15 17])
% 
% 
% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.design.stories_results_normed','XPECT.design_story_results_normed_unsmoothed');
%     movefile('XPECT.design.questions_results_normed','XPECT.design_question_results_normed_unsmoothed');
%     movefile('XPECT.design.outcomes_results_normed','XPECT.design_outcome_results_normed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.outcomes',[5 7 11 17 19],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.outcomes',[5 7 9 17 19],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_12','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.outcomes',[5 7 9 15 19],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.outcomes',[5 7 9 15 17],'unnormed')
% 
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.stories',[5 7 11 17 19],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.stories',[5 7 9 17 19],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_12','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.stories',[5 7 9 15 19],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% younglab_model_spm8_XPECT_D_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.stories',[5 7 9 15 17],'unnormed')
% 
% 
% names = makeIDs('XPECT',[1:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.design.stories_results_unnormed','XPECT.design_story_results_unnormed_unsmoothed');
%     movefile('XPECT.design.questions_results_unnormed','XPECT.design_question_results_unnormed_unsmoothed');
%     movefile('XPECT.design.outcomes_results_unnormed','XPECT.design_outcome_results_unnormed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_01','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_02','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_03','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_04','XPECT.design.outcomes',[5 7 11 17 19])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_05','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_06','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_07','XPECT.design.outcomes',[5 7 9 17 19])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_08','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_09','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_10','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_11','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_12','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_13','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_14','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_15','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_16','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_17','XPECT.design.outcomes',[5 7 9 15 19])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_18','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_19','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_20','XPECT.design.outcomes',[5 7 9 15 17])
% 
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_01','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_02','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_03','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_04','XPECT.design.stories',[5 7 11 17 19])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_05','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_06','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_07','XPECT.design.stories',[5 7 9 17 19])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_08','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_09','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_10','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_11','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_12','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_13','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_14','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_15','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_16','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_17','XPECT.design.stories',[5 7 9 15 19])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_18','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_19','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT_D('XPECT','YOU_XPECT_20','XPECT.design.stories',[5 7 9 15 17])
% 



% Random Effects

% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),3,'Stor_Beh-Non')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),4,'Stor_Beb-Men')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),6,'Stor_Men-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),7,'Stor_Soc-Nonsoc')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),8,'Stor_Nonsoc-Soc')



% younglab_RFX_spm8('XPECT','tom_localizer_results_normed',makeIDs('XPECT',[1:24]),1,'belief-photo')
% 
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),1,'Stor_Non-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),2,'Stor_Non-Men')

% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:24]),5,'Stor_Men-Non')

% 
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),1,'Ques_Non-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),2,'Ques_Non-Men')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),3,'Ques_Beh-Non')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),4,'Ques_Beh-Men')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),5,'Ques_Men-Non')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),6,'Ques_Men-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),7,'Ques_Soc-Nonsoc')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:24]),8,'Ques_Nonsoc-Soc')
% 
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),1,'Out_Non-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),2,'Out_Non-Men')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),3,'Out_Beh-Non')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),4,'Out_Beh-Men')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),5,'Out_Men-Non')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),6,'Out_Men-Beh')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),7,'Out_Soc-Nonsoc')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:24]),8,'Out_Nonsoc-Soc')
% 
% 
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),7,'UN-EN')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),8,'UB-EB')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),9,'UM-EM')
% 
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),10,'EN-UN')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),11,'EB-UB')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),12,'EM-UM')
% 
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),13,'EN-EB')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),14,'EN-EM')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),15,'EB-EN')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),16,'EB-EM')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),17,'EM-EN')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),18,'EM-EB')
% 
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),19,'UN-UB')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),20,'UN-UM')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),21,'UB-UN')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),22,'UB-UM')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),23,'UM-UN')
% younglab_RFX_spm8('XPECT','XPECT.outcome_results_normed',makeIDs('XPECT',[1:24]),24,'UM-UB')



% CLUSTER THRESHOLD

% cluster_threshold_beta(72,72,36,3,3,8,3,'none',0,0,.05,.01,1000,'cluster_threshold')
 






