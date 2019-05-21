function spm_inputs_itemwise_timesplit(root_dir,study,subjs,runs,taskname1,taskname2)
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
					f=load(fname);
					num_items=length(f.items_run);
					count = 0;
					for it=1:num_items
						% Assigns variable fields for first time segment at each trial
						spm_inputs_itemwise_timesplit(it+count).name = strcat(num2str(f.items_run(it)), '_t1'); 

						spm_inputs_itemwise_timesplit(it+count).ons = f.spm_inputs(f.entirety_run(it)).ons;
						    % onset for first portion of time series corresponds to onset of trial
						spm_inputs_itemwise_timesplit(it+count).dur = (f.spm_inputs(f.entirety_run(it)).dur) - 4;

						count = count + 1;

						% Assigns variable fields for second time segment at each trial
						spm_inputs_itemwise_timesplit(it+count).name = strcat(num2str(f.items_run(it)), '_t2'); 
							% assigns name for first 9 TRs of time split at this trial
						spm_inputs_itemwise_timesplit(it+count).ons = (f.spm_inputs(f.entirety_run(it)).ons) + 9;
						    % onset for first portion of time series corresponds to onset of trial
						spm_inputs_itemwise_timesplit(it+count).dur = (f.spm_inputs(f.entirety_run(it)).dur) - 9;
					end
					save([subjs{s} '.' taskname2 '.' num2str(r) '.mat'],'spm_inputs_itemwise_timesplit','-append');
					clear f fname;
					disp(['Successfully processed run ' num2str(r)])
			end %end runs loop
		catch
			disp(['Error with ' subjs{s}])
			continue
		end %end try
	end %end subject loop








end %end function