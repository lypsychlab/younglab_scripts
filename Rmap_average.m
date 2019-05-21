
load(fullfile('/home/younglw/lab/server/englewood/mnt/englewood/data','PSYCH-PHYS','RSA_parameters.mat'));
cd(fullfile(rootdir,study,'results','Rmap_subdom_60_2_Zscore'));
vi={};
for s=sub_nums
	vi{end+1}=fullfile(rootdir,study,[subj_tag '_' sprintf('%02d',s)],'/results/DIS_results_itemwise_normed',...
		'RSA_searchlight_regress_Rmap_subdom_60_2_Zscore.img');
end
vi=char(vi); 
vi=spm_vol(vi);
vo='Rmap_average.nii';
form = '(i1';
for i=2:39
	form = [form '+i' num2str(i)];
end
form = [form ')/39'];
q=spm_imcalc(vi,vo,form); 
clear q;