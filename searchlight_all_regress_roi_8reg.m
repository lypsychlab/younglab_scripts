function searchlight_all_regress_roi_8reg(study,subj_tag,resdir,sub_nums,conditions,sph,b1,b2,b3,b4,b5,b6,b7,b8,roiname,outtag)
% searchlight_all_regress_roi(study,sub_nums,conditions,sph,b1,b2,b3,b4):
% - performs searchlight RSA that, instead of correlating neural data
% with a design matrix, regresses four matrices
% on the neural data to extract the effects of each contrast.
% It does this within a given ROI.
% 
% The original inputs for DIS/RSA (Alek + Emily, SANS submission):
% behav_1 -> HvP (harm versus purity)
% behav_3 -> IntVAcc_conj (intentional versus accidental)
% behav_4 -> IntVAcc_HvP (interaction)
% behav_2 -> IntVAcc
%
% Parameters:
% - study: name of study folder (string)
% - subj_tag: prefix to subject names (string) e.g. SAX_DIS
% - resdir: results directory (string) e.g. tom_localizer_results_normed
% - sub_nums: subject numbers (array)
% - conditions: number of beta files to be analyzed (numerical)
% - sph: sphere size (numerical); 3 is recommended
% - b1, b2, b3, b4: tag to denote design matrices (string)
% Matrices are in the format "behav_matrix_01_tagname.mat"
% - roiname: name of ROI (e.g. 'RTPJ') (string). Should be in .../[subject]/roi directory.
%
% Output:
% - bigmat_regression_[roiname].mat: per-voxel item crosscorrelation values within the ROI
% - corrs_regression_[roiname].mat: neural/design matrix correlations


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
    disp(['Root directory: ' rootdir]);
    disp(['Subjects: ' subjIDs]);
    disp(['Study: ' study]);
    disp(['Results directory: ' resdir]);
    disp(['ID tag: ' outtag]);
    disp(['Design matrices: ' b1 ' ' b2 ' ' b3 ' ' b4 ' ' b5 ' ' b6 ' ' b7 ' ' b8 ' const']);


	cd('/younglab/scripts/');
	load voxel_order2; 

	for subj=1:length(subjIDs) %grabbing beta images

		disp(['Processing subject ' subjIDs{subj} '.']);
		load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b1 '.mat']));
        disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b1 '.mat']));
		behav_1=behav_matrix1; clear behav_matrix1;
		load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b2 '.mat']));
        disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b2 '.mat']));
		behav_2=behav_matrix2; clear behav_matrix2;
		load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b3 '.mat']));
		disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b3 '.mat']));
        behav_3=behav_matrix; clear behav_matrix;
		load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b4 '.mat']));
		disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b4 '.mat']));
        behav_4=behav_matrix; clear behav_matrix;
        load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b5 '.mat']));
		disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b5 '.mat']));
        behav_5=behav_matrix; clear behav_matrix;
        load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b6 '.mat']));
		disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b6 '.mat']));
        behav_6=behav_matrix; clear behav_matrix;
        load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b7 '.mat']));
		disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b7 '.mat']));
        behav_7=behav_matrix; clear behav_matrix;
        load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b8 '.mat']));
		disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' b8 '.mat']));
        behav_8=behav_matrix; clear behav_matrix;
        
		behav_1=sim2tril(behav_1);
		behav_2=sim2tril(behav_2);
		behav_3=sim2tril(behav_3);
		behav_4=sim2tril(behav_4);
        behav_5=sim2tril(behav_5);
        behav_6=sim2tril(behav_6);
        behav_7=sim2tril(behav_7);
        behav_8=sim2tril(behav_8);


	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:conditions
	        betafiles{i} = betadir(i).name;
	    end
	    disp('Loading beta files...')
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
	    corrs  = zeros(1,9);
        
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
        temp        = tril(simmat,-1); 
        bigmat = temp(temp~=0)';% we now have a triangle x 1 matrix

        predictors = horzcat(ones(length(behav_1),1),behav_1,behav_2,behav_3,behav_4,behav_5,behav_6,behav_7,behav_8);
        weights = regress(bigmat',predictors);

        corrs(1)=weights(2); % b1
        corrs(2)=weights(3); % b2
        corrs(3)=weights(4); % b3
        corrs(4)=weights(5); % b4
        corrs(5)=weights(6); % b5
        corrs(6)=weights(7); % b6
        corrs(7)=weights(8); % b7
        corrs(8)=weights(9); % b8

        corrs(9)=weights(1); % constant

        corrs_Z=zscore(corrs);

        clear temp simmat behav_1 behav_2 behav_3 behav_4 behav_5 behav_6 behav_7 behav_8 weights predictors
        
	    save(['bigmat_regression_' roiname outtag '.mat'], 'bigmat');
	    save (['corrs_regression_' roiname outtag '.mat'], 'corrs','corrs_Z');
	    disp('Correlations saved.');

	    clear corrs meantril
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	end % subject list
end %end searchlight_all