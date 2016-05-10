function spm_inputs_itemwise_IEH(root_dir,study,subjs,runs,taskname)
% spm_inputs_itemwise_IEH: creates new itemwise inputs variable from the
% regular spm_inputs variable.
% 
% Parameters:
% - root_dir: either "studies" or "englewood" to indicate dir structure
% - study: name of the study folder
% - subjs: cell string of subject names
% - runs: number of runs
% - taskname: name by which to identify behavioral .mats


	root_dir='/younglab/studies/';
% 	if strcmp(root_dir,'younglab')
% 		root_dir='/younglab/studies';
% 	else if strcmp(root_dir,'englewood')
% 		root_dir='/mnt/englewood/data';
% 	else
% 		disp('Unrecognized root directory!')
% 		return
% 	end

	cd(fullfile(root_dir,study,'duration60secs_behavioral'));
    disp(pwd);
	for s=1:length(subjs)
        disp(subjs{s});
		for r=1:runs
			fname=[subjs{s} '.' taskname '.' num2str(r) '.mat'];
            disp(fname);
			f=load(fname);
			num_items=length(f.design);
            
            all_ons=[];all_dur=[];
            for thing=1:length(f.spm_inputs)
                all_ons=[all_ons; f.spm_inputs(thing).ons'];
                all_dur=[all_dur; f.spm_inputs(thing).dur];
            end
            %now we have run-length lists of onsets/durations
            %add them together to sort
            all_info=[all_ons all_dur];
            %and sort by onset to get temporal order
            all_info=sortrows(all_info,1);
            
			for it=1:num_items
				spm_inputs_itemwise(it).name = [num2str(it) '_' num2str(f.design(it))];
				spm_inputs_itemwise(it).ons = all_info(it,1);
				spm_inputs_itemwise(it).dur = all_info(it,2);
			end
			save(fname,'spm_inputs_itemwise','-append');
			clear f fname all_ons all_dur all_info;
		end %end runs loop
	end %end subject loop








end %end function