
function volumes = average_ROIs(study,resdir,subjs,totalcond,numcond,rois)
% volumes = average_ROIs(study,resdir,subjs,totalcond,numcond,rois):
% - save the mean BOLD values from ROIs into a structure called volumes
%
% Parameters:
% - study: study name
% - resdir: the results subfolder in which to find betas
% - subjs: cell string of subject names
% - totalcond: total number of beta files
% - numcond: number of conditions within totalcond
% (assumes cyclical structure such that e.g. if totalcond = 60
% and numcond=10, images 1,11,21, etc. are from the same condition)
% rois: cell string of roi names (e.g. RTPJ)

	%go to each subject directory within the study directory
	%get the beta images and spm_vol each of them
	%then for each ROI mask:
	%use the mask to identify which voxels in the volume to average
	%put those voxels' values into a list
	%average the list 
	%put that averaged value into the structure
	%save the structure

	%assumes that conditions have a cyclical structure within totalcond
	%that is, beta image #1 is the same condition as image #11 if numcond=10

	globaldir='/mnt/englewood/data/';
	% resdir='/results/DIS_results_normed_smoothed/';
	resdir=['results/' resdir];
	cd(fullfile(globaldir,study));
	volumes.roinames=rois; %save the names in the volumes structure
	numrois=length(rois);
    volumes.rawvol=cell(length(subjs),numcond);
    volumes.maskedvol=cell(length(subjs),numcond,numrois);
    volumes.avgrois=cell(length(subjs),numcond,numrois);
    prev_dir=pwd;
    cd('/younglab/scripts/');
    load(['greymattermask2.mat']); load(['voxel_order2.mat']);
    cd(prev_dir);


	for sub=1:length(subjs)
        if ~isempty(subjs{sub})
		cd(fullfile(globaldir,study,subjs{sub},resdir));
		betadir=dir('beta*.img');betanames=cell(totalcond,1);fnames=cell(numcond,1);
		for b=1:totalcond
			betanames{b}=betadir(b).name;
			if mod(b,numcond)==0 %prevent indexing to 0
				fnames{numcond}=[fnames{numcond};[globaldir study '/' subjs{sub} resdir betanames{b}]];
			else
				fnames{mod(b,numcond)}=[fnames{mod(b,numcond)};[globaldir study '/' subjs{sub} resdir betanames{b}]];
            end
        end
        cond_imgs=cell(numcond,1);
		for condition=1:numcond 
			cond_imgs{condition} = spm_vol(fnames{condition}); %get header info
			[volumes.rawvol{sub}{condition},XYZ] = spm_read_vols(cond_imgs{condition}); %read volumes
		end
		clear XYZ betadir betanames fnames cond_imgs;

        prev_dir=pwd;
		% cd(fullfile('/younglab/studies/',study,subjs{sub},'uniqueROI'))
		cd(fullfile(globaldir,study,subjs{sub},'roi'))

		for roi=1:numrois
			thisroi=dir(['*' rois{roi} '*.img']); thisroi=thisroi(1).name; %get the name of the ROI img file we're masking with
			thisroi=spm_vol(thisroi);[thisroi,XYZ]=spm_read_vols(thisroi); clear XYZ;
			for condition=1:numcond
                sprintf(['S ' subjs{sub} ' C ' num2str(condition) ' R ' rois{roi}])
				mvol=make_roi_mask(volumes.rawvol{sub}{condition},thisroi,greymattermask2,voxel_order2);
				volumes.maskedvol{sub}{condition}{roi}=mvol;
				clear mvol;
				volumes.avgrois{sub}{condition}{roi}=nanmean(volumes.maskedvol{sub}{condition}{roi});
			end
        end
        cd(prev_dir);
        end %end check if subjs{sub} is empty
	end %end subject loop

	rmfield(volumes,'rawvol'); %no reason to keep this data

end
%end average_ROIs

function maskedvoxels = make_roi_mask(target,mask,gm,vorder)
    %target: the 4D neural data from which we grab voxel values
    %mask: mask with 1s to represent inclusion
    %gm: grey matter mask
    %vorder: list of voxel indices

	maskedvoxels=[];
	for v=1:length(gm)
		vindices=vorder(gm(v),:); %this voxel's indices
		if mask(vindices(1),vindices(2),vindices(3))==1
            %if our mask includes this grey-matter voxel
			vox=target(vindices(1),vindices(2),vindices(3),:);
            %add the corresponding values from the target
			maskedvoxels=[maskedvoxels; nanmean(vox)];
		else
			maskedvoxels=[maskedvoxels; NaN];
		end
    end
end %end make_roi_mask
