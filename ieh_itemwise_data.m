function ieh_itemwise_data(roinames)

    study='IEHFMRI';
    % subj_nums=[4:8 11:14 16:22 24 25]; % all subjects leaving out 5 which has to be remodeled
    subj_nums=[5];
    subjs={};sessions={};
    for s=1:length(subj_nums)
        subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
    end


    condnames={'estim' 'imagn' 'journ' 'memry'};
    %1->1
    %2->4
    %3->2
    %4->3
    rootdir='/younglab/studies';
    resdir='ieh_results_itemwise_normed';
    subjIDs=subjs;
    % roiname='Retrosplenial_R';
    
    neuro_total=[];

    for thisroi=1:length(roinames)
        roiname=roinames{thisroi};
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
                disp(['No ' roiname '; continuing to next subject']);
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
                % length(spheremeans)%should always be 10, since 10 betas per condition/subject

                    subjcolumn=[repmat([subjIDs{thissub}],length(betafiles),1)];
                    condcolumn=[repmat([condnames{thiscond}],length(betafiles),1)];
                    neuralcolumn=spheremeans';

                    all_sub_info=[all_sub_info; subjcolumn];
                    all_cond_info=[all_cond_info; condcolumn];

                all_neural_info=[all_neural_info; neuralcolumn];
        	end%end cond loop
        end%end subject loop

    neuro_total=[neuro_total all_neural_info];
    disp(['Finished with roi ' roiname])
    cd(fullfile(rootdir,study,'results'));
    save(['all_itemwise_' roiname '.mat'],'all_sub_info','all_cond_info','all_neural_info','roinames');    
    end %end roi loop
    % save('all_itemwise_allrois.mat','neuro_total','roinames');
    
end