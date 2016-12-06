function spm_inputs_itemwise_pleiades(root_dir,study,subjs,runs,taskname1,taskname2)
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
		try
			disp(['Subject ' subjs{s}])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname1 '.' num2str(r) '.mat'];
					f=load(fname,'spm_inputs');
					num_items=length(f.items_run);
					for it=1:num_items
						spm_inputs_itemwise(it).name = num2str(f.items_run(it));
						spm_inputs_itemwise(it).ons = f.spm_inputs(f.design_run(it)).ons;
						spm_inputs_itemwise(it).dur = f.spm_inputs(f.design_run(it)).dur;
					end
					save([subjs{s} '.' taskname2 '.' num2str(r) '.mat'],'spm_inputs_itemwise','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])
			end %end runs loop
		catch
			disp(['Error with ' subjs{s}])
			continue
		end %end try
	end %end subject loop








end %end function
