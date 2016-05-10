function searchlight_all_onematrix_roi(study,subj_tag,resdir,sub_nums,conditions,sph,behav_tag,roiname)
% searchlight_all(study,sub_nums,conditions,sph,behav_tag):
% - performs searchlight RSA, stepping through every voxel in the brain and
% correlating voxel patterns to design matrices in a sphere of surrounding voxels.
% 
% Parameters:
% - study: name of study folder (string)
% - subj_tag: prefix to subject names (string) e.g. SAX_DIS
% - resdir: results directory (string) e.g. tom_localizer_results_normed
% - sub_nums: subject numbers (array)
% - conditions: number of beta files to be analyzed (numerical)
% - sph: sphere size (numerical); 3 is recommended
% - behav_tag: tag to denote design matrix (string)
% Matrix is in the format "behav_matrix_01_tagname.mat"
%
% Output:
% - bigmat.mat: per-voxel item crosscorrelation values across the brain
% - corrs.mat: neural/design matrix correlations
% - [searchlight images]: .nii files prepended with "RSA_searchlight", in results dir

	subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
	end
	%behav_mat: lower triangle of behavioural matrix
	addpath('/younglab/scripts/combinator/');

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
		% load(fullfile(rootdir, study, 'behavioural' ,['behav_matrix_' subjIDs{subj} '_' behav_tag '.mat']));
		load(fullfile(rootdir, study, 'behavioural' ,['behav_matrix_' behav_tag '.mat']));
		% behav_matrix=behav_matrix((c1+1):c2,(c1+1):c2);
        behav_matrix = sim2tril(behav_matrix);

	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:conditions
	        betafiles{i} = betadir(i).name;
        end
	    disp('Loading beta files...')
	    % keyboard
	    betafiles
%         disp([repmat([fullfile(rootdir,study,subjIDs{subj},'results/DIS_results_itemwise_normed/')],conditions,1) char(betafiles) repmat(',1',conditions,1)]);
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],conditions,1) char(betafiles) repmat(',1',conditions,1)]); %spm_vol reads header info
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
	    triangle = ((conditions^2)/2)-(conditions/2);
	    bigmat = zeros(mask_length,triangle);
	    corrs  = zeros(1); 
	    spherebetas = zeros(mask_length,conditions);

	    
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

        % keyboard
        temp=corrcoef( behav_matrix , bigmat' );
        corrs(1)=temp(2,1);


	    clear temp simmat behav_matrix
	    save(['bigmat_' roiname '_' behav_tag '.mat'], 'bigmat');
	    save (['corrs_' roiname '_' behav_tag '.mat'], 'corrs');
	    disp('Correlations saved.');

	    clear corrs meantril
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	end % subject list
end %end searchlight_all