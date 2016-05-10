function rsa_sim(root_dir,study,sub_nums,subj_tag,rname,num_items,stddev_range,num)

	% initialize cell array of subjects:
	subjs={};
	for thissub=1:length(sub_nums)
		subjs{end+1}=[subj_tag '_' sprintf('%02d',sub_nums(thissub))];
    end
    subjs

	dname=fullfile(root_dir,study);
	for stddev = stddev_range
		foldertag=[num2str(num) '_' num2str(stddev)];
		for thissub=1:length(subjs)
			fprintf(['Running subject ' subjs{thissub} '...\n']);
			try
				[r1 r2] = simulate_rois(dname,subjs{thissub},rname);
			catch
				fprintf(['simulate_rois failed for subject ' subjs{thissub} '; continuing to next subject.\n']);
				continue;
			end
			R = repmat([r1 r2],1,num_items);
			for this_r=1:size(R,2)
				R(:,this_r)=R(:,this_r)+(stddev*randn(size(R,1),1));
			end
			fprintf('Saving output...\n')
            mkdir(fullfile(root_dir,study,subjs{thissub},'results/simulation',foldertag));
			save(fullfile(root_dir,study,subjs{thissub},'results/simulation',foldertag,[subjs{thissub} '.mat']),'R');

		end % end subject loop
	end % end stddev loop

function [r1 r2] = simulate_rois(dirname,subj,rname)

	cd(fullfile(dirname,subj,'roi'));
	roidir=dir(['*' rname '*img']);
	if length(roidir) == 0
		fprintf(['No ' rname ' found for ' subj '\n']);
		fprintf(['Ending simulate_rois.\n']);
		return;
	else
		thisroi=roidir(1).name;
	end

	% get the size of the roi:
	thisroi=spm_vol(thisroi);
	thisroi=spm_read_vols(thisroi);
	thisroi=find(thisroi~=0);
	roi_size=length(thisroi);

	% generate the underlying matrices: 
	r1=randi([0 1],roi_size,1);
	r2=randi([0 1],roi_size,1);

end % end simulate_rois

end % end rsa_sim