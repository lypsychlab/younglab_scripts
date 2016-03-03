cd /mnt/englewood/data/PSYCH-PHYS/behavioural;
load subject_ids;
sub_nums=sub_nums(2:end);

% for s=1:length(sub_nums)
% 	try
% 		itemwise_neural('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(s),60,{'LIFG' 'RTPJ' 'PC'},'test')
% 	catch
% 		disp(['Error on subject ' num2str(sub_nums(s)) '; continuing']);
% 	end
% end
% load subj_groups;
% nums_NT=sub_nums(NT);nums_NT=nums_NT(2:end);
% nums_ASD=sub_nums(ASD);
% nums_NT
% nums_ASD
for roi_ind=1:3
	process_itemwise_neural_separate('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed','DIS',6,sub_nums,60,roi_ind,'test','sep');
	% process_itemwise_neural('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed','DIS',6,nums_NT,60,roi_ind,'test','NT');
	% process_itemwise_neural('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed','DIS',6,nums_ASD,60,roi_ind,'test','ASD');

end
