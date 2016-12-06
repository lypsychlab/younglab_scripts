%younglab_dicom_convert('XPECT','YOU_XPECT_17')
%younglab_dicom_convert('XPECT','YOU_XPECT_18')
%younglab_dicom_convert('XPECT','YOU_XPECT_19')
%younglab_dicom_convert('XPECT','YOU_XPECT_20')

% younglab_preproc_temporal('XPECT','YOU_XPECT_17')
% younglab_preproc_spatial('XPECT','YOU_XPECT_17')
% younglab_preproc_temporal('XPECT','YOU_XPECT_18')
% younglab_preproc_spatial('XPECT','YOU_XPECT_18')
% younglab_preproc_temporal('XPECT','YOU_XPECT_19')
% younglab_preproc_spatial('XPECT','YOU_XPECT_19')

%younglab_model_spm8_lily('XPECT','YOU_XPECT_17','XPECT.story',[5 7 9 15 19])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_17','XPECT.question',[5 7 9 15 19])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_17','XPECT.outcome',[5 7 9 15 19])

%younglab_model_spm8_lily('XPECT','YOU_XPECT_18','XPECT.story',[5 7 9 15 17])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_18','XPECT.question',[5 7 9 15 17])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_18','XPECT.outcome',[5 7 9 15 17])

%younglab_model_spm8_lily('XPECT','YOU_XPECT_19','XPECT.story',[5 7 9 15 17])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_19','XPECT.question',[5 7 9 15 17])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_19','XPECT.outcome',[5 7 9 15 17])
 
%younglab_model_spm8_lily('XPECT','YOU_XPECT_20','XPECT.story',[5 7 9 15 17])
%younglab_model_spm8_lily('XPECT','YOU_XPECT_20','XPECT.question',[5 7 9 15 17])
%younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_20','XPECT.outcome',[5 7 9 15 17])



% names = makeIDs('XPECT',1:20);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.outcome_results_normed','XPECT.outcome_results_normed_2mm');
% end

% names = makeIDs('XPECT',1:20);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.story_results_normed','XPECT.story_results_normed_2mm');
%     movefile('XPECT.question_results_normed','XPECT.question_results_normed_2mm');
% end



% DIS models

% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_03','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_04','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_05','DIS.domain',[10 12 14 20 22 24])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_06','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_07','DIS.domain',[12 14 16 22 24 26])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_08','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_09','DIS.domain',[10 12 14 20 22 24])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_10','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_11','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_12','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_13','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_14','DIS.domain',[12 14 16 22 24 26])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_27','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_28','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_32','DIS.domain',[8 10 12 20 22 24])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_34','DIS.domain',[8 10 12 18 20 22])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_38','DIS.domain',[4 6 8 14 16 18])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_40','DIS.domain',[4 6 8 14 16 18])
% younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_41','DIS.domain',[4 8 10 16 18 20])
younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_42','DIS.domain',[4 6 8 14 16 18])
younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_43','DIS.domain',[4 6 8 10 16 18])
younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_45','DIS.domain',[4 6 8 14 16 18])
younglab_model_spm8_ameliaD_unsmoothed('DIS','SAX_DIS_46','DIS.domain',[4 6 8 14 16 18])

younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_03','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_04','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_05','DIS.domint',[10 12 14 20 22 24])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_06','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_07','DIS.domint',[12 14 16 22 24 26])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_08','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_09','DIS.domint',[10 12 14 20 22 24])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_10','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_11','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_12','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_13','DIS.domint',[8 10 12 18 20 22])
% younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_14','DIS.domint',[12 14 16 22 24 26])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_27','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_28','DIS.domint',[8 10 12 18 20 22])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_32','DIS.domint',[8 10 12 20 22 24])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_34','DIS.domint',[8 10 12 18 20 22])
% younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_38','DIS.domint',[4 6 8 14 16 18])
% younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_40','DIS.domint',[4 6 8 14 16 18])
% younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_41','DIS.domint',[4 8 10 16 18 20])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_42','DIS.domint',[4 6 8 14 16 18])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_43','DIS.domint',[4 6 8 10 16 18])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_45','DIS.domint',[4 6 8 14 16 18])
younglab_model_spm8_amelia_unsmoothed('DIS','SAX_DIS_46','DIS.domint',[4 6 8 14 16 18])

% 
% names = makeIDs('XPECT',[1:11 13:20]);
% for i=1:length(names)
%     % goes into the results folder of each participant
%     cd(['/younglab/studies/XPECT/' names{i} '/results/']);
%     movefile('XPECT.expect.stories_results_normed','XPECT.expect_story_results_normed_unsmoothed');
%     movefile('XPECT.expect.questions_results_normed','XPECT.expect_question_results_normed_unsmoothed');
%     movefile('XPECT.expect.outcomes_results_normed','XPECT.expect_outcome_results_normed_unsmoothed');
% end
% 
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_01','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_02','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_03','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_04','XPECT.expect.outcomes',[5 7 11 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_05','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_06','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_07','XPECT.expect.outcomes',[5 7 9 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_08','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_09','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_10','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_11','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_13','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_14','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_15','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_16','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_17','XPECT.expect.outcomes',[5 7 9 15 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_18','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_19','XPECT.expect.outcomes',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_20','XPECT.expect.outcomes',[5 7 9 15 17])
% 
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_01','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_02','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_03','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_04','XPECT.expect.stories',[5 7 11 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_05','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_06','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_07','XPECT.expect.stories',[5 7 9 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_08','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_09','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_10','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_11','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_13','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_14','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_15','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_16','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_17','XPECT.expect.stories',[5 7 9 15 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_18','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_19','XPECT.expect.stories',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_20','XPECT.expect.stories',[5 7 9 15 17])
% 
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_01','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_02','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_03','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_04','XPECT.expect.questions',[5 7 11 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_05','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_06','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_07','XPECT.expect.questions',[5 7 9 17 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_08','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_09','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_10','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_11','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_13','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_14','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_15','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_16','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_17','XPECT.expect.questions',[5 7 9 15 19])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_18','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_19','XPECT.expect.questions',[5 7 9 15 17])
% younglab_model_spm8_XPECT('XPECT','YOU_XPECT_20','XPECT.expect.questions',[5 7 9 15 17])


% DESIGN models

% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.outcomes',[5 7 11 17 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.outcomes',[5 7 9 17 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.outcomes',[5 7 9 15 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.outcomes',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.outcomes',[5 7 9 15 17])
% 
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.stories',[5 7 11 17 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.stories',[5 7 9 17 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.stories',[5 7 9 15 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.stories',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.stories',[5 7 9 15 17])
% 
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_01','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_02','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_03','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_04','XPECT.design.questions',[5 7 11 17 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_05','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_06','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_07','XPECT.design.questions',[5 7 9 17 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_08','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_09','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_10','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_11','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_13','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_14','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_15','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_16','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_17','XPECT.design.questions',[5 7 9 15 19])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_18','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_19','XPECT.design.questions',[5 7 9 15 17])
% younglab_model_spm8_lily_unsmoothed('XPECT','YOU_XPECT_20','XPECT.design.questions',[5 7 9 15 17])


% Random Effects

% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),1,'Story_N_v_B')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),2,'Story_N_v_M')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),3,'Story_B_v_N')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),4,'Story_B_v_M')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),5,'Story_M_v_N')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),6,'Story_M_v_B')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),7,'Story_Soc_v_Nonsoc')
% younglab_RFX_spm8('XPECT','XPECT.design.stories_results_normed',makeIDs('XPECT',[1:11 13:20]),8,'Story_Nonsoc_v_Soc')
% 
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),1,'Quest_N_v_B')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),2,'Quest_N_v_M')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),3,'Quest_B_v_N')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),4,'Quest_B_v_M')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),5,'Quest_M_v_N')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),6,'Quest_M_v_B')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),7,'Quest_Soc_v_Nonsoc')
% younglab_RFX_spm8('XPECT','XPECT.design.questions_results_normed',makeIDs('XPECT',[1:11 13:20]),8,'Quest_Nonsoc_v_Soc')
% 
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),1,'Out_N_v_B')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),2,'Out_N_v_M')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),3,'Out_B_v_N')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),4,'Out_B_v_M')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),5,'Out_M_v_N')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),6,'Out_M_v_B')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),7,'Out_Soc_v_Nonsoc')
% younglab_RFX_spm8('XPECT','XPECT.design.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),8,'Out_Nonsoc_v_Soc')
% 
% younglab_RFX_spm8('XPECT','XPECT.expect.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),1,'Out_Exp_v_Unexp')
% younglab_RFX_spm8('XPECT','XPECT.expect.outcomes_results_normed',makeIDs('XPECT',[1:11 13:20]),2,'Out_Unexp_v_Exp')


% Cluster Threshold

% cluster_threshold_beta(72,72,36,3,3,8,3,'none',0,0,.05,.01,1000,'cluster_threshold')
 






