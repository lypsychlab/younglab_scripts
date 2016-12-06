function roi_svm(rootdir,study,subj_tag,resdir,sub_nums,conditions,g1,g2,cnames,roiname,outfile)
%
% Parameters:
% - study: name of study folder (string)
% - subj_tag: prefix to subject names (string) e.g. SAX_DIS
% - resdir: results directory (string) e.g. tom_localizer_results_normed
% - sub_nums: subject numbers (array)
% - conditions: number of beta files to be analyzed (numerical)
% - g1: design numbers delineating class 1
% - g2: design numbers delineating class 2
% - cnames: 1x2 cell array of class names
% - roiname: name of ROI (e.g. 'RTPJ') (string). Should be in .../[subject]/roi directory.
% - outfile: tag for resulting .mat file



	subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
	end

	%rootdir ='/mnt/englewood/data/';

	cd('/younglab/scripts/');
	load voxel_order2; 

    output_nums=[];
    
	for subj=1:length(subjIDs) %grabbing beta images

	disp(['Processing subject ' subjIDs{subj} '.']);
    
    cd(fullfile(rootdir,study,'behavioural'));
    taskname='DIS';
    load([subjIDs{subj} '.' taskname '.1.mat']);
    labels_numeric=zeros(conditions,1);
    for it = 1:conditions
        thisit=find(items==it); %subject-specific index for item it
        if ismember(design(thisit),g2) %design coding for item it
            labels_numeric(it)=1;
        end
    end

    labeled_data=cell(conditions,1);
    for l = 1:conditions
        if labels_numeric(l)==1
            labeled_data{l}=cnames{2};
        else
            labeled_data{l}=cnames{1};
        end
    end
    
	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:length(betafiles)
	        betafiles{i} = betadir(i).name;
	    end
	    disp('Loading beta files...')
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],conditions,1) char(betafiles) repmat(',1',conditions,1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes


	    disp('Getting mask image...')
	    prev_dir=pwd;
	    cd(fullfile(rootdir,study,subjIDs{subj},'roi'));
    	roidir=dir(['ROI_' roiname '*img']);
    	if isempty(roidir)
        disp(['No ' roiname ' for subject ' subjIDs{subj} '; continuing to next subject']);
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
        
    	clear mask_img;

<<<<<<< HEAD
	
=======
	    disp(['Processing correlations...'])
	    triangle = ((conditions^2)/2)-(conditions/2);
	    bigmat = zeros(mask_length,triangle);
	    corrs  = zeros(1);
>>>>>>> 4ea36e0abf8da612bbc2f8f0c2b7dc72c0a45376
        
	    spherebetas = zeros(mask_length,conditions);
        
        for one_beta=1:conditions
            this_beta=Y(:,:,:,one_beta);
            for icoords = 1:mask_length % for each voxel
                spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
            end
        end
        
        spherebetas=spherebetas';
        accuracy=younglab_svm(spherebetas,labeled_data,cnames,...
            fullfile(rootdir,study,subjIDs{sub},'results',[subjIDs{subj} '.' outfile]));
        output_nums=[output_nums; accuracy];
	end % subject list
    cd(fullfile(rootdir,study));
    save(['allsubs_' outfile],'output_nums');
end %end searchlight_all