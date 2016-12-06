function searchlight_all_regress_roi_pleiades(rootdir,study,subj_tag,resdir,sub_nums,conditions,sph,B_in,roiname,outtag)
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


	spheresize=(2*sph)-1;
	%notice that the number of voxels in your sphere increases exponentially with sphere size.
	%for example, sph=2 corresponds to 7 shifts. sph=3 : 81 shifts. sph=4 : 275 shifts. sph=5 : 637 shifts.
	%reminder to be conservative about choosing sphere size
	move_coords=(6*(spheresize-2)^2)+(spheresize-2)^3; %the number of unique shift combinations to obtain coordinates w/in sphere
	v=-(sph-2):(sph-2);
	vindices_1=combinator(length(v),3,'p','r');
	vindices_2=combinator(length(v),2,'p','r');
	c1=v(vindices_1); c2=v(vindices_2);
	edge=repmat(sph-1,length(c2),1); %vector of repeated edge number
	coords=[c1; [edge c2]; [-edge c2]; [c2 edge]; [c2 -edge]; [c2(:,1) edge c2(:,2)]; [c2(:,1) -edge c2(:,2)]];
	%what this does: all permutations without any 'edge numbers' + perms with an edge number in position x, y, or z respectively 
	%edge number = sph-1 or -(sph-1).


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
		B=[];
		for b=1:length(B_in)
			try
				load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' B_in{b} '.mat']));
		        disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' B_in{b} '.mat']));
		        behav_matrix=sim2tril(behav_matrix);
				B=[B behav_matrix];
				clear behav_matrix;
			catch
				load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' B_in{b} '.mat']));
		        disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' B_in{b} '.mat']));
		        behav_matrix=sim2tril(behav_matrix);
				B=[B behav_matrix];
				clear behav_matrix;
			end
		end

		try
	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
		catch
			continue
		end
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
	    cd(fullfile(rootdir,study,subjIDs{sub},'roi'));
    	roidir=dir(['ROI_' roiname '*img']);
    	
    	if isempty(roidir)
    		cd(fullfile(rootdir,study,'ROI'));
    		roidir=dir(['ROI_' roiname '*nii']);
    	end

    	if isempty(roidir)
        disp(['No ' roiname ' for subject ' subjIDs{sub} '; continuing to next subject']);
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

    	disp(['Processing correlations...'])
	    triangle = ((conditions^2)/2)-(conditions/2);
	    bigmat = zeros(mask_length,triangle);
	    spherebetas = zeros(mask_length,conditions);
	    spear=[];
	    for one_beta=1:conditions
            this_beta=Y(:,:,:,one_beta);
            for icoords = 1:mask_length % for each voxel
                spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
            end
        end
        clear Y;
        goodrows = find(isnan(spherebetas(:,1)) == 0);
        simmat      = corrcoef(spherebetas(goodrows,:));% item similarities for this subject
        temp        = tril(simmat,-1); % tril() gets lower triangle of matrix
        bigmat = temp(temp~=0)';% we now have a triangle x 1 matrix

        predictors = horzcat(ones(size(B,1),1),B);
	    [weights,bint,Rval,Rint,Stats] = regress(bigmat',predictors);
	    weights=weights';

	    corrs=[weights(2:end) weights(1)];

	    thisspear = corr([bigmat' predictors],'type','Spearman');
	    thisspear=thisspear(1,:); %only grab correlations of empirical data with predictors
	    thisspear=[thisspear(2:end) thisspear(1)];
	    spear=thisspear;

	    clear temp simmat behav_1 behav_2 weights predictors thisspear

 	    save(['bigmat_' roiname outtag '.mat'], 'bigmat');
	    save(['corrs_' roiname outtag '.mat'], 'corrs');
	    save(['spearman_' roiname outtag '.mat'], 'spear');
	   	save(['regressinfo_' roiname outtag '.mat'], 'corrs','bint','Rval','Rint','Stats');


	    disp('Correlations saved.');

	    clear corrs meantril spear bint Rval Rint Stats;
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	    toc
	end % subject list
end %end searchlight_all