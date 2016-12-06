% check_rsa:

rootdir='/home/younglw/server/englewood/DIS_MVPA';
study='DIS_MVPA';
addpath(genpath('/home/younglw/scripts'));
load subject_ids;
for s=1:length(sub_nums)
	cd(fullfile(rootdir,study,sprintf('SAX_DIS_%02d',sub_nums(s)),'results/DIS_results_itemwise_normed'));
	disp(sprintf('SAX_DIS_%02d:',s));
	tagnames={'HvP_H_48', 'HvP_P_48','IntVAcc_Int_48','IntVAcc_Acc_48','Int_H','Int_P','Acc_H','Acc_P'};
	for t=1:length(tagnames)
		d=dir(['RSA_searchlight_regress_' tagnames{t} '*img']);
		disp([tagnames{t} ': ' num2str(length(d))]);
	end
end