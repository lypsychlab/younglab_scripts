function searchlight_all_regress_five(study,subj_tag,resdir,sub_nums,conditions,sph,b1,b2,b3,b4,b5,outtag)
% searchlight_all_regress(study,subj_tag,resdir,sub_nums,conditions,sph,b1,b2,b3,b4,outtag):
% - performs searchlight RSA that, instead of correlating neural data
% with a design matrix within each sphere, regresses four matrices
% on the neural data to extract the effects of each contrast.
% 
% The original inputs for DIS/RSA (Alek + Emily, SANS submission):
% b1 -> HvP (harm versus purity)
% b2 -> IntVAcc
% b3 -> IntVAcc_conj (intentional versus accidental)
% b4 -> IntVAcc_HvP (interaction)
%
% New inputs (1.21.16):
% b1 -> HvP_48 (harm vs purity, neutral items excluded)
% b2 -> IntVAcc_48 (intentional vs accidental)
% b3 -> IntVAcc_winH_48 (intent effect within harm domain)
% b4 -> IntVAcc_winP_48 (intent effect within purity domain)
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
% - outtag: suffix to distinguish your output files (string)
%
% Output:
% - bigmat_regression.mat: per-voxel item crosscorrelation values across the brain
% - corrs_regression.mat: neural/design matrix regression weights
% This is a (number of voxels) x 5 matrix, last column is the constant regressor
% - [searchlight images]: .nii files prepended with "RSA_searchlight_regress", in results dir

	addpath('/younglab/scripts/combinator')
	subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
    end

	rootdir ='/mnt/englewood/data/';

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
    save(fullfile(rootdir,study,'coords.mat'),'coords');
    
    disp(['Root directory: ' rootdir]);
    disp(['Subjects: ' subjIDs]);
    disp(['Study: ' study]);
    disp(['Results directory: ' resdir]);
    disp(['ID tag: ' outtag]);
    disp(['Design matrices: ' b1 ' ' b2 ' ' b3 ' ' b4 ' ' b5 ' const']);


	cd('/younglab/scripts/');
	load voxel_order2; 
    load greymattermask2;

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
        
		behav_1=sim2tril(behav_1);
		behav_2=sim2tril(behav_2);
		behav_3=sim2tril(behav_3);
		behav_4=sim2tril(behav_4);
        behav_5=sim2tril(behav_5);

	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:conditions
	        betafiles{i} = betadir(i).name;
	    end
	    disp('Loading beta files...')
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],conditions,1) char(betafiles) repmat(',1',conditions,1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes

	    disp(['Processing correlations...'])
	    triangle = ((conditions^2)/2)-(conditions/2);
	    bigmat = zeros(length(greymattermask2),triangle);
	    corrs  = zeros(length(greymattermask2),6); 
	    for i = 1:length(greymattermask2)% for each voxel
	        sphere      = repmat(voxel_order2(greymattermask2(i),:),length(coords),1) + coords; 
	        spherebetas = zeros(length(coords),conditions);
	        for icoords = 1:length(coords) % get beta values for sphere voxels
                try
                    spherebetas(icoords,:) = Y(sphere(icoords,1), sphere(icoords,2), sphere(icoords,3), :);
                catch
                    continue
                end
	        end
	        goodrows = find(isnan(spherebetas(:,1)) == 0);
	        if length(goodrows) > 9 % if there are at least 10 good voxels in this sphere
	            simmat      = corrcoef(spherebetas(goodrows,:));% item similarities for this subject
	            temp        = tril(simmat,-1); % tril() gets lower triangle of matrix
	            bigmat(i,:) = temp(temp~=0)';% we now have a triangle x 1 matrix

	            % temp        = corrcoef( behav_matrix , bigmat(i,:)' ); %correlation with behavioral matrix
	            predictors = horzcat(ones(length(behav_1),1),behav_1,behav_2,behav_3,behav_4,behav_5);
	            weights = regress(bigmat(i,:)',predictors);

	            % corrs(i)    = temp(2,1); %save a correlation value for this voxel
	            corrs(i,1)=weights(2); % b1
	            corrs(i,2)=weights(3); % b2
	            corrs(i,3)=weights(4); % b3
	            corrs(i,4)=weights(5); % b4
	            corrs(i,5)=weights(6); % b5
                corrs(i,6)=weights(1); % constant

	        end
	    end
	    clear temp simmat behav_1 behav_2 behav_3 behav_4 behav_5 weights predictors

	    save(['bigmat_regression' outtag '.mat'], 'bigmat');
	    save (['corrs_regression' outtag '.mat'], 'corrs');
	    disp('Correlations saved.');
	    corrmap_1  = zeros(size(Y(:,:,:,1))); 
	    corrmap_2  = zeros(size(Y(:,:,:,1))); 
	    corrmap_3  = zeros(size(Y(:,:,:,1))); 
	    corrmap_4  = zeros(size(Y(:,:,:,1))); 
	    corrmap_5  = zeros(size(Y(:,:,:,1))); 
        corrmap_6  = zeros(size(Y(:,:,:,1)));
        clear Y;

	    for i=1:length(greymattermask2) 
	            corrmap_1(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,1);
				corrmap_2(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,2);
				corrmap_3(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,3);
				corrmap_4(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,4);
				corrmap_5(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,5);
                corrmap_6(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,6);
	    end
	    disp('Creating template...');

	    template_dir=dir('beta_*nii');
	    template       = spm_vol([fullfile(rootdir,study,subjIDs{subj},'results', resdir,template_dir(1).name) ',1']);
	    template.fname = ['RSA_searchlight_regress_' b1 outtag '.img']; spm_write_vol(template,corrmap_1);
	   	template.fname = ['RSA_searchlight_regress_' b2 outtag '.img']; spm_write_vol(template,corrmap_2);
	   	template.fname = ['RSA_searchlight_regress_' b3 outtag '.img']; spm_write_vol(template,corrmap_3);
	   	template.fname = ['RSA_searchlight_regress_' b4 outtag '.img']; spm_write_vol(template,corrmap_4);
        template.fname = ['RSA_searchlight_regress_' b5 outtag '.img']; spm_write_vol(template,corrmap_5);
	   	template.fname = ['RSA_searchlight_regress_const_' outtag '.img']; spm_write_vol(template,corrmap_6);

	    clear corrs meantril
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	end % subject list
end %end searchlight_all