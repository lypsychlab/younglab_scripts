function spm_inputs_itemwise(root_dir,study,subjs,runs,taskname)
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
	if strcmp(root_dir,'studies')
		root_dir='/younglab/studies';
	else if strcmp(root_dir,'englewood')
		root_dir='/mnt/englewood/data';
	else
		disp('Unrecognized root directory!')
		return
	end

	cd(fullfile(root_dir,study,'behavioural'));
	for s=1:length(subjs)
		for r=1:runs
			fname=[subjs{s} '.' taskname '.' num2str(r) '.mat'];
			f=load(fname);
			num_items=length(f.items_run);
			for it=1:num_items
				spm_inputs_itemwise(it).name = num2str(f.items_run(it));
				spm_inputs_itemwise(it).ons = f.spm_inputs(f.design_run(it)).ons;
				spm_inputs_itemwise(it).dur = f.spm_inputs(f.design_run(it)).dur;
			end
			save(fname,'spm_inputs_itemwise','-append');
			clear f fname;
		end %end runs loop
	end %end subject loop








end %end function
