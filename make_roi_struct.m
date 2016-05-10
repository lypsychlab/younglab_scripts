function [roi_struct] = make_roi_struct(study,subjIDs)
	roi_struct=struct('names',[],'files',[]);
	prev_dir=pwd;
	for sub=1:length(subjIDs)
		cd(fullfile('/younglab/studies',study,subjIDs{sub},'roi'));
		d=fullfile(pwd,'ROI_*xyz.img');
		roi_file_dir=dir(d);
		for fl=1:length(roi_file_dir)
			roi_file=fullfile(pwd,roi_file_dir(fl).name);
			roi_struct.names{fl}=roi_file_dir(fl).name(5:9);
			roi_struct.files{fl}{sub}=roi_file;
		end
	end
	cd(prev_dir);

end %end make_roi_struct