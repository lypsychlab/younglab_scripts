function con_info_FB_adults(root_dir,study,subjs,runs,taskname)
% spm_inputs_itemwise: creates new itemwise inputs variable from the
% regular spm_inputs variable.
%
% Parameters:
% - root_dir: either "studies" or "englewood" to indicate dir structure
% - study: name of the study folder
% - subjs: cell string of subject names
% - runs: number of runs
% - taskname: name by which to identify behavioral .mats


	% root_dir='/younglab/studies/';
	% if strcmp(root_dir,'studies')
	% 	root_dir='/home/younglw';
	% else if strcmp(root_dir,'englewood')
	% 	root_dir='/home/younglw/server/englewood/mnt/englewood/data';
	% else
	% 	disp('Unrecognized root directory!')
	% 	return
	% end
	% end

	cd(fullfile(root_dir,study,'behavioural'));
	disp(pwd);
	for s=1:length(subjs)
		%try
			disp(['Subject ' subjs{s} 's con_info'])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.0' num2str(r) '.mat'];
					f=load(fname);
					clear con_info
					con_info(1).name  = 'experimental(coop & comp) > neutral';
					con_info(1).vals  = [0.5 0.5 -1];
					con_info(2).name  = 'cooperative > competitive';
					con_info(2).vals  = [1 -1 0];
					con_info(3).name  = 'competitive > cooperative';
					con_info(3).vals  = [-1 1 0];
					con_info(4).name  = 'cooperative > neutral';
					con_info(4).vals  = [1 0 -1];
					con_info(5).name  = 'competitive > neutral';
					con_info(5).vals  = [0 1 -1];

					save([subjs{s} '.' taskname '.0' num2str(r) '.mat'],'con_info','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])

			end %end runs loop

	end %end subject loop





end %end function
