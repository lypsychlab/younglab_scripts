function grab_roi_info(study,subjs,roitag,localizer_dir,contrast_num,outname)
	rootdir='/home/younglw/lab';
	mkdir(fullfile(rootdir,study,'ROI',outname));
	ROI_center=zeros(3,length(subjs));
	ROI_voxels=zeros(1,length(subjs));
	ROI_peakT=zeros(1,length(subjs));
	for s = 1:length(subjs)
		% load information from the .mat files
		cd(fullfile(rootdir,study,subjs{s},'roi'));
		d=dir([roitag '.mat']);
		if length(d)>0
			f=load(d(1).name);
			ROI_name=f.xY.name;
			ROI_center(:,s)=f.xY.xyz;
			ROI_voxels(:,s)=size(f.ROI.XYZ,2);
			clear f;
		end
		% use imcalc to mask the T image and find peak voxel
		d=dir([roitag '.img']);
		if length(d)>0
			maskfile=fullfile(pwd,d(1).name);
			cd(fullfile(rootdir,study,subjs{s},'results',localizer_dir));
			Timage=fullfile(pwd,['spmT_' sprintf('%04d',contrast_num) '.img']);
			out_image={Timage maskfile};
			out_image=char(out_image);
        	out_image=spm_vol(out_image);
        	tempfile='temp.img';
            tempimage=spm_imcalc(out_image,tempfile,'i1.*i2');
            tempimage=spm_vol('temp.img');
            tempimage=spm_read_vols(tempimage);
            ROI_peakT(1,s)=max(max(max(tempimage)));
            delete('temp.img');
        end
	end
	cd(fullfile(rootdir,study,'ROI',outname));
	save([outname '.mat'],'ROI_center','ROI_voxels','ROI_peakT','ROI_name','subjs');
end