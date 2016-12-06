% This script moves itemwise beta files generated in order of presentation
% so that their index matches their item number instead.
function move_itemwise_dumb(subj_nums)

% root_dir='/home/younglw/server/englewood/DIS_MVPA/';
root_dir='/home/younglw/';

study='VERBS';

subjs={};sessions={};
% subj_nums=[3];
% subj_nums=[4:20 22:24 27:35 37:42 44:47]; 
% subj_nums=[4 5];
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
end

for s=1:length(subjs)
	% try
		cd(fullfile(root_dir,study,'behavioural'));
		fprintf(['Recoding subject ' subjs{s} '\n']);
		items=[];
		for r=[1 2 3 4 6]
			f=load([subjs{s} '.DIS.' num2str(r) '.mat']);
			items=[items f.items_run]; clear f;
		end
		cd(fullfile(root_dir,study,subjs{s},'/results/DIS_verbs_results_concat_itemwise_normed'));
		betadir=dir('beta_0*nii');
		for c=1:50
			newind=items(c);
			movefile(betadir(c).name,['beta_item_' sprintf('%02d',newind) '.nii']);
		end
	% catch
	% 	fprintf(['Error: could not process subject ' subjs{s} '\n']);
	% 	continue
	% end
end
end % end function