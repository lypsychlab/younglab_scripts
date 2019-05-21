function spm_inputs_FB_adults(root_dir,study,subjs,runs,taskname)
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
			disp(['Subject ' subjs{s} 's spm_inputs'])
			for r=1:runs
				disp(['Run ' num2str(r)])
					fname=[subjs{s} '.' taskname '.0' num2str(r) '.mat'];
					f=load(fname);
					clear spm_inputs
					spm_inputs(1).name = 'coo';
					spm_inputs(2).name = 'com';
					spm_inputs(3).name = 'neu';
					
					for trial = 1:3
						spm_inputs(trial).ons = [];
						spm_inputs(trial).dur = [15;15];
					end	
					onsets = [6,21,36,51,66,81]; %pre-defined onset values
					for trial=1:length(f.cond_run)
						if f.cond_run(trial)==1 %if condition is cooperative							
							spm_inputs(1).ons = [spm_inputs(1).ons, onsets(trial)]; %assign onset for this trial to appropriate index in spm_inputs

						elseif f.cond_run(trial)==2 %if condition is competitive
							spm_inputs(2).ons = [spm_inputs(2).ons, onsets(trial)]; %assign onset for this trial to appropriate index in spm_inputs
						
						else
							spm_inputs(3).ons = [spm_inputs(3).ons, onsets(trial)];
						
						end

					end
					save([subjs{s} '.' taskname '.0' num2str(r) '.mat'],'spm_inputs','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])

			end %end runs loop

	end %end subject loop





end %end function