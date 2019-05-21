function spm_inputs_harm_pure(root_dir,study,subjs,runs,taskname1,taskname2)
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

	cd(fullfile(root_dir,study,'behavioural_harm_pur'));
	disp(pwd);
	for s=1:length(subjs)
		%try
			disp(['Subject ' subjs{s}])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname1 '.' num2str(r) '.mat'];
					f=load(fname);
					num_items=length(f.items_run);
					for it=1:num_items
						% Assigns variable fields for first time segment at each trial
						condstring = char(f.condnames(it))
						if ismember(condstring(3:end), {'PHI', 'PHA', 'PSI', 'PSA'})
							spm_inputs(it).name = 'harm';
							spm_inputs(it).ons = f.spm_inputs(it).ons
							spm_inputs(it).dur = f.spm_inputs(it).dur
						elseif ismember(condstring(3:end), {'II', 'IA', 'PI', 'PA'})
							spm_inputs(it).name = 'purity';
							spm_inputs(it).ons = f.spm_inputs(it).ons
							spm_inputs(it).dur = f.spm_inputs(it).dur
						else
							spm_inputs(it).name = 'neutral';
							spm_inputs(it).ons = f.spm_inputs(it).ons
							spm_inputs(it).dur = f.spm_inputs(it).dur

						end
							


					end
					save([subjs{s} '.' taskname2 '.' num2str(r) '.mat'],'spm_inputs','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])
			end %end runs loop
		%catch
			%disp(['Error with ' subjs{s}])
			%continue
		%end %end try
	end %end subject loop








end %end function