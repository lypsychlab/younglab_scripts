function move_rois(rootdir,study,subj_tag,subj_nums,rname)
% move_rois:
% copy group rois to subject-specific folders

	mkdir(fullfile(rootdir,study,'logs'));
	diary(fullfile(rootdir,study,'logs',['move_rois_' date '.txt']));

	subjs={};

	for s=1:length(subj_nums)
	    subjs{end+1}=[subj_tag sprintf('%02d',subj_nums(s))];
	end
	

	cd(fullfile(rootdir,study,'ROI'));
	img=dir(['*' rname '*img']);
	if length(img)>0
		img=img(1).name;
		hdr=dir(['*' rname '*hdr']);
		hdr=hdr(1).name;
		for s=1:length(subjs)
			copyfile(img,fullfile(rootdir,study,subjs{s},'roi'));
			copyfile(hdr,fullfile(rootdir,study,subjs{s},'roi'));
		end
	end

	nifti=dir(['*' rname '*nii']);
	if length(nifti)>0
		nifti=nifti(1).name;
		for s=1:length(subjs)
			copyfile(nifti,fullfile(rootdir,study,subjs{s},'roi'));
		end
	end

	diary off;
end %end function