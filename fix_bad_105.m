% cd(fullfile('/younglab/studies','IEHFMRI','YOU_IEHFMRI_105','results/ieh_results_itemwise_normed'));
% betadir=dir('beta_item*.nii');
% for thisbeta=1:120
% 	% movefile(betadir(thisbeta).name,['beta_item_' sprintf('%03d',num2str(thisbeta)) '_' betanames{thisbeta}]);
% 	badcode=sprintf('%03d',num2str(thisbeta));
% 	badbeta=dir(['beta_item_' badcode '*nii']);
% 	badbeta=badbeta(1).name; %should only be one bad one per bad code
% 	keep_these=badbeta(end-8:end); %keeps the within-run code & the condition code, e.g. _12_6.nii
% 	goodname=['beta_item_' sprintf('%03d',thisbeta) keep_these];
% 	goodname
% 	badbeta
% 	% movefile(badbeta,goodname);
% end

cd(fullfile('/younglab/studies','IEHFMRI','YOU_IEHFMRI_105','results/ieh_results_itemwise_normed'));
betadir=dir('beta_item*.nii');
for thisbeta=1:120
	oldbeta=betadir(thisbeta).name; 
	expr='_\d{1}_'; %any single number between two underscores
	if ~isempty(regexp(oldbeta,expr,'match'))
		oldnum=regexp(oldbeta,expr,'match');
		oldnum=oldnum{1}(2);
		newnum=sprintf('%02s',oldnum);
		newname=regexprep(oldbeta,expr,['_' newnum '_']);
		movefile(oldbeta,newname);
	end
end
