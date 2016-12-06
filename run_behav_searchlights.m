behavnames={'intentional_purity' 'intentional_harm' 'accidental_purity' 'accidental_harm' 'intenteffect_harm'};
matrixnames={'HvP' 'IntVAcc' 'IntVAcc_winH' 'IntVAcc_winP'};
for m=1:length(matrixnames)
	matrixnames{m}=['regress_' matrixnames{m} '_48'];
end
for b=1:length(behavnames)
	for m=1:length(matrixnames)
		searchlight_behavioral('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',matrixnames{m},behavnames{b},...
			['BrainBehav' matrixnames{m} '_' behavnames{b}]);
	end
end
