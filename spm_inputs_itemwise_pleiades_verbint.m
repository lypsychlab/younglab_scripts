function spm_inputs_itemwise_pleiades_verbint(root_dir,study,subjs,runs,taskname1,taskname2)
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
		% try
			disp(['Subject ' subjs{s}])

			for r=1:runs
				disp(['Run ' num2str(r)])
				fname=[subjs{s} '.' taskname1 '.' num2str(r) '.mat'];
				f=load(fname);
				if exist('f.spm_inputs_itemwise')==1
					clear f.spm_inputs_itemwise;
				end
				% num_items=length(f.items_run);
				f.spm_inputs=f.spm_inputs(10:12); %this is specific to verbint
				onsvec=[];durvec=[];
				for inp=1:length(f.spm_inputs)
					onsvec=[onsvec; f.spm_inputs(inp).ons];
					durvec=[durvec f.spm_inputs(inp).dur];
				end
				allvec = [onsvec durvec'];
				allvec = sortrows(allvec,1); %order of presentation

				itemvec=f.items(((r-1)*10+1):((r-1)*10+10));
				for it=1:length(itemvec)
				spm_inputs_itemwise(it).name = num2str(itemvec(it));
				spm_inputs_itemwise(it).ons = allvec(it,1);
				spm_inputs_itemwise(it).dur = allvec(it,2);
				end
				save([subjs{s} '.' taskname2 '.' num2str(r) '.mat'],'spm_inputs_itemwise','-append');
				clear f fname allvec onsvec durvec;
			end
			
			
					% disp(['Successfully processed run ' num2str(r)])
			% end %end runs loop
		% catch
		% 	disp(['Error with ' subjs{s}])
		% 	continue
		% end %end try
	end %end subject loop








end %end function
