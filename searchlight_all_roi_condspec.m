function searchlight_all_roi_condspec(study,subj_tag,resdir,sub_nums,conditions,sph,behav_tag,roiname,condinds)
% searchlight_all_roi_condspec(study,sub_nums,conditions,sph,b1,b2,b3,b4):
% - performs searchlight RSA within a given ROI,for a given condition.
% Assumes that your conditions are grouped logically within your results
% subdirectory as betas (condinds(1)) to (condinds(2)).
%
% Parameters:
% - study: name of study folder (string)
% - subj_tag: prefix to subject names (string) e.g. SAX_DIS
% - resdir: results directory (string) e.g. tom_localizer_results_normed
% - sub_nums: subject numbers (array)
% - conditions: number of beta files to be analyzed (numerical)
% - sph: sphere size (numerical); 3 is recommended
% - behav_tag: tag to denote design matrices (string)
% Matrices are in the format "behav_matrix_01_tagname.mat"
% - roiname: name of ROI (e.g. 'RTPJ') (string). Should be in .../[subject]/roi directory.
%
% Output:
% - bigmat_[roiname]_[behav_tag].mat: per-voxel item crosscorrelation values within the ROI
% - corrs_[roiname]_[behav_tag].mat: neural/design matrix correlations


	addpath('/younglab/scripts/combinator/');
	subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
	end
	%behav_mat: lower triangle of behavioural matrix

	%these lines are dumb, but leave them in as a placeholder in the event of later edits
	% rootdir = '/ncf/mcl/03/alek/';
	rootdir ='/mnt/englewood/data/'
	% folders = dir([rootdir '1*']); %modify depending on dir structure
	% study=study;
	% subjIDs = [1:7 9:18];
	% subjIDs=subjIDs;
	% conditions=conditions; %number of conditions

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


	cd('/younglab/scripts/');
	load voxel_order2; 

	for subj=1:length(subjIDs) %grabbing beta images

		disp(['Processing subject ' subjIDs{subj} '.']);
		% load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b1 '.mat']));
		% behav_1=behav_matrix; clear behav_matrix;
		% load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b2 '.mat']));
		% behav_2=behav_matrix; clear behav_matrix;
		% load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b3 '.mat']));
		% behav_3=behav_matrix; clear behav_matrix;
		% load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b4 '.mat']));
		% behav_4=behav_matrix; clear behav_matrix;
		% behav_1=sim2tril(behav_1);
		% behav_2=sim2tril(behav_2);
		% behav_3=sim2tril(behav_3);
		% behav_4=sim2tril(behav_4);
		load(fullfile(rootdir, study, 'behavioural' ,['behav_matrix_' subjIDs{subj} '_' behav_tag '.mat']));
        behav_matrix = sim2tril(behav_matrix);

	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
	    betadir = dir('beta_item*nii');betafiles=cell(length(condinds(1):condinds(2)),1);
        betadir=betadir(condinds(1):condinds(2));
	    for i=1:length(betadir)
	        betafiles{i} = betadir(i).name;
        end
        betafiles
        short_conditions=length(betafiles);
	    disp('Loading beta files...')
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],short_conditions,1) char(betafiles) repmat(',1',short_conditions,1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes


	    disp('Getting mask image...')
	    prev_dir=pwd;
	    cd(fullfile(rootdir,study,subjIDs{sub},'roi'));
    	roidir=dir(['ROI_' roiname '*img']);
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
	    triangle = ((short_conditions^2)/2)-(short_conditions/2);
	    bigmat = zeros(mask_length,triangle);
	    corrs  = zeros(1);
        
	    spherebetas = zeros(mask_length,short_conditions);
        
        for one_beta=1:short_conditions
            this_beta=Y(:,:,:,one_beta);
            for icoords = 1:mask_length % for each voxel
                spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
            end
        end
        clear Y;
        goodrows = find(isnan(spherebetas(:,1)) == 0);
        simmat      = corrcoef(spherebetas(goodrows,:));% item similarities for this subject
        temp        = tril(simmat,-1); 
        bigmat = temp(temp~=0)';% we now have a triangle x 1 matrix

        temp=corrcoef( behav_matrix , bigmat' );
        % predictors = horzcat(ones(length(behav_1),1),behav_1,behav_2,behav_3,behav_4);
        % weights = regress(bigmat',predictors);

        corrs(1)=temp(2,1);
        % corrs(1)=weights(2); % harm versus purity
        % corrs(2)=weights(3); % intentional versus accidental
        % corrs(3)=weights(4); % interaction
        % corrs(4)=weights(5); % interaction
        % corrs(5)=weights(1); % constant
        % corrs_Z=zscore(corrs);

	    clear temp simmat behav_matrix 

	    save(['bigmat_' roiname '_' behav_tag '.mat'], 'bigmat');
	    save (['corrs_' roiname '_' behav_tag '.mat'], 'corrs');
	    disp('Correlations saved.');

	    clear corrs meantril
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	end % subject list
end %end searchlight_all