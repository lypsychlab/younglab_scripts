% behavnames={'intentional_purity' 'intentional_harm' 'accidental_purity' 'accidental_harm' 'intenteffect_harm'};
% matrixnames={'HvP' 'IntVAcc' 'IntVAcc_winH' 'IntVAcc_winP'};
% for m=1:length(matrixnames)
% 	matrixnames{m}=[matrixnames{m} '_48'];
% end
% 
% for sub=1:length(sub_nums)
% 		searchlight_all_regress('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,4,matrixnames{1},...
%             matrixnames{2},matrixnames{3},matrixnames{4},'_sph4');
% 	end
% 
% % behavnames={'intentional_purity' 'intentional_harm' 'accidental_purity' 'accidental_harm' 'intenteffect_harm'};
% cd /mnt/englewood/data/PSYCH-PHYS/behavioural;
% load subject_ids;
% % matrixnames={'HvP' 'IntVAcc' 'IntVAcc_winH' 'IntVAcc_winP'};
% % for m=1:length(matrixnames)
% % 	matrixnames{m}=[matrixnames{m} '_48'];
% % end
% % 
% % for sub=1:length(sub_nums)
% % 		searchlight_all_regress('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,3,...
% %             'HvP_48','IntVAcc_48','IntVAcc_winH_48zeroes','IntVAcc_winP_48zeroes','_zeroes');
% % 	end
% 
% for sub=1:length(sub_nums)
% 		searchlight_all_regress_five('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,3,...
%             'HvP_H_48','HvP_P_48','IntVAcc_48','IntVAcc_winH_48zeroes','IntVAcc_winP_48zeroes','_fivereg');
% end
%     
cd /mnt/englewood/data/PSYCH-PHYS/behavioural;
load subject_ids;
% matrixnames={'HvP' 'IntVAcc' 'IntVAcc_winH' 'IntVAcc_winP'};
% for m=1:length(matrixnames)
% 	matrixnames{m}=[matrixnames{m} '_48'];
% end
% 
% for sub=1:length(sub_nums)
% 		searchlight_all_regress('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,3,...
%             'HvP_48','IntVAcc_48','IntVAcc_winH_48zeroes','IntVAcc_winP_48zeroes','_zeroes');
% 	end
% 
% for sub=1:length(sub_nums)
% 		searchlight_all_regress_six('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,3,...
%             'HvP_H_48','HvP_P_48','IntVAcc_Int_48','IntVAcc_Acc_48','IntVAcc_winH_48zeroes','IntVAcc_winP_48zeroes','_sixreg');
% end
%     

% for sub=1:length(sub_nums)
% 		searchlight_all_regress_eight('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,3,...
%             'HvP_H_48','HvP_P_48','IntVAcc_Int_48','IntVAcc_Acc_48','Int_H','Int_P','Acc_H','Acc_P','_8reg');
% 	end
% 
% for sub=1:length(sub_nums)
% 		searchlight_all_regress_purity('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),24,3,...
%             'IntVAcc_Int_P_24','IntVAcc_Acc_P_24','_Ponly');
% end
    
% for sub=1:length(sub_nums)
% 		searchlight_all_harm('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),24,3,...
%             'IntVAcc_HARM_24','_corr_Honly');
% end
%     
% for sub=1:length(sub_nums)
%     searchlight_all_regress_roi_8reg('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),48,3,...
%             'HvP_H_48','HvP_P_48','IntVAcc_Int_48','IntVAcc_Acc_48','Int_H','Int_P','Acc_H','Acc_P','PC','_8reg');
% end

for sub=1:length(sub_nums)
    searchlight_all_roi_harm('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(sub),24,3,'IntVAcc_PURITY_24','PC','_Ponly');
end