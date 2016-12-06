sub_nums=[3:6 7:20 22:24 27:35 38:42 44 45 47];
subjs={};
for thissub=1:length(sub_nums)
	subjs{end+1}=['SAX_DIS_' sprintf('%02d',sub_nums(thissub))];
end
for thiss=1:length(subjs)
	% try
		cd(fullfile('/home/younglw/VERBS/behavioural'));
		spm_inputs_itemwise_pleiades_verbint('/home/younglw','VERBS',{subjs{thiss}},6,'DIS_verbint2','DIS_verbint2');
		spm_inputs_itemwise_pleiades_verbint('/home/younglw','VERBS',{subjs{thiss}},6,'DIS_verbint1','DIS_verbint1');
	% catch
	% 	disp(['Failed for ' subjs{thiss}]);
	% end
end
