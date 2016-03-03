% This script moves itemwise beta files generated in order of presentation
% so that their index matches their item number instead.


root_dir='/mnt/englewood/data/';
study='PSYCH-PHYS';

subjs={};sessions={};
% subj_nums=[3:47];
subj_nums=[3];
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
end

s=1;
% for s=3:length(subjs)
	try
		cd(fullfile(root_dir,study,'behavioural'));
		f=load([subjs{s} '.DIS.1.mat']);
		items=f.items; clear f;
		cd(fullfile(root_dir,study,subjs{s},'/results/DIS_results_itemwise_normed'));
		betadir=dir('beta_0*nii');
		for c=1:60
			newind=items(c);
			movefile(betadir(c).name,['beta_item_' sprintf('%02d',newind) '.nii']);
		end
	catch
		disp(['Error: could not process subject ' subjs{s}])
		continue
	end
% end
