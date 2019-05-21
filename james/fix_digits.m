function fix_digits(inp)

% inp=[3:6 7:20 22:24 27:35 38:42 44 45 47];


for thiss=1:length(inp)
	cd(fullfile('/home/younglw/VERBS',sprintf('SAX_DIS_%02d',inp(thiss)),'results/DIS_verbint1_results_concat_itemwise_normed'));
	for i=1:9
		nm=['beta_item_' num2str(i) '.nii'];
		if exist(nm)~=0
			newnm=['beta_item_' sprintf('%02d',i) '.nii'];
			movefile(nm,newnm);
		else
			disp(['No file ' nm ' for subject ' sprintf('SAX_DIS_%02d',inp(thiss)) ' in verbint1'])
			continue
		end
	end
	cd(fullfile('/home/younglw/VERBS',sprintf('SAX_DIS_%02d',inp(thiss)),'results/DIS_verbint2_results_concat_itemwise_normed'));
	for i=1:9
		nm=['beta_item_' num2str(i) '.nii'];
		if exist(nm)~=0
			newnm=['beta_item_' sprintf('%02d',i) '.nii'];
			movefile(nm,newnm);
		else
			disp(['No file ' nm ' for subject ' sprintf('SAX_DIS_%02d',inp(thiss)) ' in verbint1'])
			continue
		end
	end
end


end %end function