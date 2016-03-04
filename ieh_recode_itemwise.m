study='IEHFMRI';
subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
end

cd(fullfile('/younglab/studies',study,'duration60secs_behavioral'));

for thissub=1:length(subjs)
	betanames=[];

	for thisrun=1:8
		fname=[subjs{thissub} '.ieh.' num2str(thisrun) '.mat'];
		f=load(fname);
		names=cell(length(f.spm_inputs_itemwise),1);
		for thisitem=1:length(f.spm_inputs_itemwise)
			betanames=[betanames;f.spm_inputs_itemwise(thisitem).name '.nii'];
		end
	end

	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_itemwise_results_normed'));
	betadir=dir('beta_*.nii');
	for thisbeta=1:length(betadir)
		movefile(betadir(thisbeta).name,['beta_item_' num2str(thisbeta) '_' betanames(thisbeta,:)]);
	end

end