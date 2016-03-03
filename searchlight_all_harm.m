function searchlight_all_harm(study,subj_tag,resdir,sub_nums,conditions,sph,behav_tag,outtag)
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

	for subj=1:length(subjIDs) %grabbing beta images

		disp(['Processing subject' subjIDs{subj} '.']);
		load(fullfile(rootdir, study, 'behavioural' ,['behav_matrix_' subjIDs{subj} '_' behav_tag '.mat']));
        behav_matrix = sim2tril(behav_matrix);

	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));
	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:conditions
	        betafiles{i} = betadir(i).name;
        end
        betafiles
	    disp('Loading beta files...')
%         disp([repmat([fullfile(rootdir,study,subjIDs{subj},'results/DIS_results_itemwise_normed/')],conditions,1) char(betafiles) repmat(',1',conditions,1)]);
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],conditions,1) char(betafiles) repmat(',1',conditions,1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes

	    disp(['Processing correlations...'])
	    triangle = ((conditions^2)/2)-(conditions/2);
	    bigmat = zeros(length(greymattermask2),triangle);
	    corrs  = zeros(length(greymattermask2),1); 
	    for i = 1:length(greymattermask2)% for each voxel
	        sphere      = repmat(voxel_order2(greymattermask2(i),:),81,1) + coords; 
	        %81 stacked copies of (the xyz coordinates for that voxel plus sphere location)
	        %81 = the number of voxels in the sphere
	        spherebetas = zeros(81,conditions);
	        for icoords = 1:81 % get beta values for sphere voxels
	            spherebetas(icoords,:) = Y(sphere(icoords,1), sphere(icoords,2), sphere(icoords,3), :);
	            %each of the 81 rows contains 90 beta values read off of Y for that voxel
	        end
	        goodrows = find(isnan(spherebetas(:,1)) == 0);
	        if length(goodrows) > 9 % if there are at least 10 good voxels in this sphere
	            simmat      = corrcoef(spherebetas(goodrows,:));% item similarities for this subject
	            temp        = tril(simmat,-1); % tril() gets lower triangle of matrix
	            bigmat(i,:) = temp(temp~=0)';% we now have a triangle x 1 matrix
	            temp        = corrcoef( behav_matrix , bigmat(i,:)' ); %correlation with behavioral matrix
	            corrs(i)    = temp(2,1); %save a correlation value for this voxel
	        end
	    end
	    clear temp simmat behav_matrix
	    save(['bigmat_' behav_tag '.mat'], 'bigmat')
	    save(['corrs' behav_tag '.mat'], 'corrs');
	    disp('Correlations saved.');
	    corrmap  = zeros(size(Y(:,:,:,1))); %template size?
	    for i=1:length(greymattermask2) %yeah looks like it
	            corrmap(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i);
	    end
	    disp('Creating template...');

        template_dir=dir(fullfile(rootdir,study,subjIDs{subj},'results', resdir,'beta_*.nii'));
	    template       = spm_vol([fullfile(rootdir,study,subjIDs{subj},'results', resdir,template_dir(1).name) ',1']);
	    template.fname = ['RSA_searchlight_' behav_tag outtag '.img']; spm_write_vol(template,corrmap);
	    clear corrs meantril
	    disp(['Subject' subjIDs{subj} 'complete.'])
	end % subject list
end %end searchlight_all