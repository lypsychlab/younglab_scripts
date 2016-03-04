study='IEHFMRI';
subj_nums=[4 6:8 11:14 16:22 24 25]; % all subjects leaving out 5 which has to be remodeled
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
end


condnames={'estim' 'imagn' 'journ' 'memry'};
rootdir='/younglab/studies';
resdir='ieh_results_itemwise_normed';
subjIDs=subjs;
roiname='Retrosplenial_R';
all_sub_info=[];
all_cond_info=[];
all_neural_info=[];

for thissub=1:length(subjs)
	disp(['Processing subject ' subjs{thissub}]);

	for thiscond=1:length(condnames)
		disp(['Processing condition ' condnames{thiscond}]);
		cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
		betadir=dir(['beta_item*' num2str(thiscond) '.nii']);
		betafiles=cell(length(betadir),1);

		for i=1:length(betafiles)
	        betafiles{i} = betadir(i).name;
	    end
	    disp('Loading beta files...')
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{thissub},'results',[resdir '/'])],length(betafiles),1) char(betafiles) repmat(',1',length(betafiles),1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir XYZ %read volumes

	    disp('Getting mask image...')
	    prev_dir=pwd;
	    cd(fullfile(rootdir,study,'ROI'));
    	roidir=dir(['*' roiname '*img']);
    	if isempty(roidir)
        disp(['No ' roiname ' for subject ' subjIDs{thissub} '; continuing to next subject']);
        continue
    	end
    	disp('Processing mask...')
    	mask_img=spm_vol(roidir(1).name);
    	mask_img.fname=fullfile(pwd,mask_img.fname);
        disp(['Mask file: ' mask_img.fname]);
    	mask_img=spm_read_vols(mask_img);
    	cd(prev_dir);
    	mask_inds = find(mask_img~=0);
        mask_length=length(mask_inds);
        disp(['Voxels in ROI: ' num2str(mask_length)]);

        spherebetas = zeros(mask_length,length(betafiles));
        for one_beta=1:length(betafiles)
            this_beta=Y(:,:,:,one_beta);
            for icoords = 1:mask_length % for each voxel
                spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
                %columns = betas; rows = voxels
            end
        end

        spheremeans=nanmean(spherebetas); %column means

        subjcolumn=[repmat([subjIDs{thissub}],length(betafiles),1)];
        condcolumn=[repmat([condnames{thiscond}],length(betafiles),1)];
        neuralcolumn=spheremeans';

        all_sub_info=[all_sub_info; subjcolumn];
        all_cond_info=[all_cond_info; condcolumn];
        all_neural_info=[all_neural_info; neuralcolumn];

		% for thisbeta=1:length(betadir)
		% 	item_tag=betadir(thisbeta).name(11:13);
		% 	if strcmp(item_tag(3),'_')
		% 		item_tag=sprintf('%03d',str2num(item_tag(1:2)));
		% 		newname=[betadir(thisbeta).name(1:10) item_tag betadir(thisbeta).name(13:end)];
		% 		movefile(betadir(thisbeta).name,newname);
		% 	end
		% end
	end
end

cd(fullfile(rootdir,study,'results'));
save(['all_itemwise_' roiname '.mat'],'all_sub_info','all_cond_info','all_neural_info');