function collect_voxel_data(infile)
% function collect_voxel_data(infile):
% - collects X x Y x Z x num_beta_images matrix of beta values for each subject.
% - infile must be the FULL PATH to your input file.
% 
% infile must have:
% rootdir (str),
% study(str), 
% subjtag (str),
% subnums (numerical array), 
% resdir (str), 
% betanums (numerical array), 
% beta_ext (str)
% masktemplate (cell array)
% - if masking all subjects with the same mask (in the ROI directory), it'll be length 1
% - otherwise, it'll be length (numsubjects)
% - and will grab the files out of the subject-specific roi subdirs
	addpath(genpath('/usr/public/spm/spm12'));
	f=load(infile);
	% build array of subjects
	subjs={};
	for s = f.subnums
		subjs{end+1}=sprintf([f.subjtag '_%02d'],s);
	end
	maskfile={};
	data_struct=struct();
	for s=1:length(subjs)
		% go to the subject directory
		cd(fullfile(f.rootdir,f.study,subjs{s},'results',f.resdir));
		% find mask file for this subject
		if ~isempty(f.masktemplate)
			if length(f.masktemplate)==1 % group mask
				maskf=dir(fullfile(f.rootdir,f.study,'ROI',f.masktemplate{1}));
			else % subject-specific mask
				maskf=dir(fullfile(f.rootdir,f.study,subjs{s},'roi', f.masktemplate{1}));
			end
			maskfile{end+1}=fullfile(f.rootdir,f.study,subjs{s},'roi',maskf(1).name);
		end
		% make cell struct to hold beta names
		betafiles=cell(length(f.betanums),1);
		all_imgs = [];
		for b=1:length(f.betanums)
			betafiles{b}=fullfile(f.rootdir,f.study,subjs{s},'results',f.resdir,sprintf(['beta_%04d' f.beta_ext],f.betanums(b)));
			% keyboard
			% mask the image, if a masktemplate is specified
			if ~isempty(f.masktemplate)
				vi={betafiles{b} maskfile{s}};
				vi=char(vi); 
				vi=spm_vol(vi);
				vo=sprintf(['beta_%04d_masked' f.beta_ext],f.betanums(b));
				form='i1.*i2';
				q=spm_imcalc(vi,vo,form); clear q;
				betafiles{b}=vo; % grab masked beta when reading vols
			end
			all_imgs=[all_imgs; [betafiles{b} ',1']];
		end
		% keyboard
		all_imgs=spm_vol(all_imgs); % read in all the data
		% keyboard
		[Y,XYZ]=spm_read_vols(all_imgs); clear XYZ;
		for b=1:length(f.betanums)
			Y_=Y(:,:,:,b); % just one beta image
			if b==1 % initialize array for stretched beta values
				beta_values=zeros(length(f.betanums),size(Y_,1)*size(Y_,2)*size(Y_,3));
			end
			%stretch into 1 x num_voxels vector
			beta_values(b,:)=reshape(Y_,[1,size(Y_,1)*size(Y_,2)*size(Y_,3)]); 
		end
		if ~isempty(f.masktemplate)
			% remove non-ROI voxels
			inds = find(beta_values(1,:) > 0);
			beta_values = beta_values(:,inds);
		end
		eval(['data_struct.' subjs{s} '=beta_values;']); clear Y Y_ beta_values;
	end
	save(infile,'data_struct','-append');		

end