% This script carries out searchlight analysis using all the design matrices indicated
% in behav_tags. These design matrices should exist in .../[study]/behavioural already.

behav_tags={'HvP' 'IntVAcc' 'IntVAcc_HARM' 'IntVAcc_PURITY' 'physVpsychVincVpath' 'IntVAcc_HvP'};
sub_nums=[3:47];
for subj=1:length(sub_nums)
	for tag=1:length(behav_tags)
		try
			searchlight_all('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums(subj),60,3,behav_tags{tag});
		catch
			disp(['Failed on subject ' num2str(sub_nums(subj)) 'with tag ' behav_tags{tag}]);
			continue
		end
	end
end