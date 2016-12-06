% This script moves itemwise beta files generated in order of presentation
% so that their index matches their item number instead.
function move_itemwise_niftis_pleiades(subj_nums,resdir)

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
	try
		% cd(fullfile(root_dir,study,'behavioural'));
		% fprintf(['Recoding subject ' subjs{s} '\n']);
		cd(fullfile(root_dir,study,subjs{s},'/results/',resdir));
		f=load('SPM.mat');
		betadir=dir('beta_0*nii');
		for c=1:length(f.SPM.Sess(1).U)
			newind=f.SPM.Sess(1).U(c).name{1};
			movefile(betadir(c).name,['beta_item_' newind '.nii']);
		end
		clear f;
	catch
		fprintf(['Error: could not process subject ' subjs{s} '\n']);
		continue
	end
end
end % end function