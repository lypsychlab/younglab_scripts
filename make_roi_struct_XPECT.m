function [roi_struct] = make_roi_struct_XPECT(study,subjIDs)
	roi_struct=struct('names',[],'files',[]);
	prev_dir=pwd;
    roinames={'LTPJ' 'DMPFC' 'PC' 'RTPJ'};
	for sub=1:length(subjIDs)
		cd(fullfile('/younglab/studies',study,subjIDs{sub},'roi'));
        for i=1:length(roinames)
            d=[pwd,'/ROI_' roinames{i} '*.img'];
            roi_file_dir=dir(d);
                roi_file=fullfile(pwd,roi_file_dir(1).name);
                roi_struct.names{i}=roi_file_dir(1).name(5:9);
                roi_struct.files{i}{sub}=roi_file;
        end
	end
	cd(prev_dir);

end %end make_roi_struct