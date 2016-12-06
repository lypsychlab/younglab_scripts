function searchlight_MDS_roi_pleiades(rootdir,study,subj_tag,resdir,sub_nums,conditions,roiname,outtag)
% searchlight_all_regress_roi(rootdir,study,subj_tag,resdir,sub_nums,conditions,sph,B_in,roiname,outtag):
% - performs searchlight RSA within a given ROI, using 1 to n matrix regressors 
% to model the empirical neural similarities.
% 
% Parameters:
% - rootdir:
% - study: name of study folder (string)
% - subj_tag: prefix to subject names (string) e.g. SAX_DIS
% - resdir: results directory (string) e.g. tom_localizer_results_normed
% - sub_nums: subject numbers (array)
% - conditions: array indicating first and last indices of beta files to load
% Ex. conditions = [1:48] will load beta_item_01.nii to beta_item_48.nii
% - sph: sphere size (numerical); 3 is recommended
% - B_in: cell array of strings, each of which denotes a regressor matrix to load
% The nth matrix must be in the format "behav_matrix_*.mat" where * is B_in{n}
% and must be stored in a variable within that .mat named behav_matrix
% - roiname: name of ROI (string). E.g. 'RTPJ'
% - outtag: string to label this analysis. Must start with '_'
%
% Output:
% - bigmat*.mat: per-voxel item crosscorrelation values in this ROI
% - corrs*.mat: regression weights for each regressor
% - spear*.mat: Spearman correlations of every predictor with the vector of neural similarities
% 
% Notes:
% - in corrs*.mat and spear*.mat, the LAST value represents the constant (intercept) regressor.


	subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
	end
	addpath('/home/younglw/scripts/combinator/');
	addpath(genpath('/usr/public/spm/spm12'));



	cd('/home/younglw/scripts/');
	%find_structure is a slightly more user-friendly way to load .mats 
	%and will eventually be capable of searching multiple directories, for disorganized users
	% find_structure(voxel_order,rootdir,study); % x y z coordinates of voxels in entire volume. stops 3 voxels from edge
	% %find_structure(load_coords,rootdir,study); % relative coordinates specifying a sphere
	% find_structure(greymattermask,rootdir,study); % indices of voxel_order that cover grey matter in a standard MNI brain
	% find_structure(comp_mat,rootdir,study);% behavioral similarity model for comparison; triangle x 1 matrix
	load voxel_order2;
    load greymattermask2;

    % c1=conditions(1);c2=conditions(2);
    % conditions=c2-c1;

	for subj=1:length(subjIDs) %grabbing beta images

		disp(['Processing subject ' subjIDs{subj} '.']);
		tic
	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));

	    c1=conditions(1);
	    conditions=length(conditions);

	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:conditions
	        betafiles{i} = betadir((i-1)+c1).name;
        end
	    disp('Loading beta files...')
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],conditions,1) char(betafiles) repmat(',1',conditions,1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes

	    disp('Getting mask image...')
	    prev_dir=pwd;
	    cd(fullfile(rootdir,study,'ROI'));
    	roidir=dir(['ROI_' roiname '*img']);
    	if isempty(roidir)
    		roidir=dir(['ROI_' roiname '*nii']);
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

    	disp(['Processing correlations...'])
	    spherebetas = zeros(mask_length,conditions);
	    for one_beta=1:conditions
            this_beta=Y(:,:,:,one_beta);
            for icoords = 1:mask_length % for each voxel
                spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
            end
        end
        clear Y;
        goodrows = find(isnan(spherebetas(:,1)) == 0);
        simmat      = corrcoef(spherebetas(goodrows,:));
        % item similarities for this subject
     	MDS_matrix = cmdscale(abs(simmat));


 	    save(['simmat_' roiname outtag '.mat'], 'simmat');
 	    save(['MDS_' roiname outtag '.mat'],'MDS_matrix');
 	    save(['spherebetas_' roiname outtag '.mat'],'spherebetas');
	    disp('Correlations saved.');

	    clear goodrows simmat MDS_matrix spherebetas;
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	    toc
	end % subject list
end %end searchlight_all