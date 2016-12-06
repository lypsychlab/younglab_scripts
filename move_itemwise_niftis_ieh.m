% This script moves itemwise beta files generated in order of presentation
% so that their index matches their item number instead.
function move_itemwise_niftis_ieh(subj_nums)

root_dir='/younglab/studies/';
study='IEHFMRI';

subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',s)];
end

s=1;
	try
		cd(fullfile(root_dir,study,'behavioural'));
		f=load([subjs{s} '.IEH.1.mat']);
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

end