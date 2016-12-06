% roi_mvpa('VERBS',[3],'DIS_verbs_results_concat_itemwise_normed',1,'RTPJ','KnewVSaw_RTPJ');
% roi_mvpa('VERBS',[3],'DIS_verbs_results_concat_itemwise_normed',2,'RTPJ','KnewVSaw_RTPJ');
% roi_mvpa('VERBS',[3],'DIS_verbs_results_concat_itemwise_normed',3,'RTPJ','KnewVSaw_RTPJ');
sub_nums=[3:6 7:20 22:24 27:35 38:42 44 45 47];
% roi_mvpa('VERBS',sub_nums,'DIS_verbs_results_concat_itemwise_normed',1,'RTPJ','KnewVSaw_RTPJ')
% roi_mvpa('VERBS',sub_nums,'DIS_verbs_results_concat_itemwise_normed',2,'RTPJ','KnewVRealize_RTPJ')
% roi_mvpa('VERBS',sub_nums,'DIS_verbs_results_concat_itemwise_normed',3,'RTPJ','SawVRealize_RTPJ')
% roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbs_results_concat_itemwise_normed',1,'RTPJ','L2_KnewVSaw_RTPJ')
% roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbs_results_concat_itemwise_normed',2,'RTPJ','L2_KnewVRealize_RTPJ')
% roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbs_results_concat_itemwise_normed',3,'RTPJ','L2_SawVRealize_RTPJ')


roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbint2_results_concat_itemwise_normed',1,'RTPJ','L2_KvS_INT_RTPJ')
roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbint2_results_concat_itemwise_normed',2,'RTPJ','L2_KvR_INT_RTPJ')
roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbint2_results_concat_itemwise_normed',3,'RTPJ','L2_SvR_INT_RTPJ')

roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbint1_results_concat_itemwise_normed',1,'RTPJ','L2_KvS_INTJUD_RTPJ')
roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbint1_results_concat_itemwise_normed',2,'RTPJ','L2_KvR_INTJUD_RTPJ')
roi_mvpa_leavetwo('VERBS',sub_nums,'DIS_verbint1_results_concat_itemwise_normed',3,'RTPJ','L2_SvR_INTJUD_RTPJ')


%NOTES
% need to fix 37: run 5 got duplicated in spm_inputs_itemwise
%excluding 43 and 46 because only have 5 runs 
% need to fix 14: runs 2-6 got moved into slots 1-5, and 6 was duplicated
