function itemwise_neural(study,subj_tag,resdir,sub_num,items,rois,outtag)

OUT=zeros(length(items),length(rois));

sub=[subj_tag '_' sprintf('%02d',sub_num)];
rootdir='/mnt/englewood/data';
cd(fullfile(rootdir,study,sub,'results',resdir));

cd('/younglab/scripts/');
	load voxel_order2; 
    load greymattermask2;

disp('Loading beta files...');
cd(fullfile(rootdir,study,sub,'results',resdir));
betadir = dir('beta_item*nii');betafiles=cell(items,1); 
for i=1:items
    betafiles{i} = betadir(i).name;
end
betafiles
subimg    = spm_vol([repmat([fullfile(rootdir,study,sub,'results',[resdir '/'])],items,1) char(betafiles) repmat(',1',items,1)]); %spm_vol reads header info
[Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes

for r=1:length(rois)
	disp(['Getting mask image for roi ' rois{r} '...']);
    prev_dir=pwd;
    cd(fullfile(rootdir,study,sub,'roi'));
	roidir=dir(['ROI_' rois{r} '*img']);
	if isempty(roidir)
	    disp(['No ' rois{r} ' for subject ' sub '; continuing to next subject']);
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

	spherebetas = zeros(mask_length,items);
    disp('Grabbing data from betafiles...');
    for one_beta=1:items
        this_beta=Y(:,:,:,one_beta);
        for icoords = 1:mask_length % for each voxel
            spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
        end
        OUT(one_beta,r)=nanmean(spherebetas(:,one_beta));
    end
end
% go to that subject's resdir
% load up the itemwise betas
% per beta
	% mask with a roi
	% nanmean the beta values in that roi
	% put that value at OUT(item #,roi #)
clear Y;

cd(fullfile(rootdir,study,sub,'results',resdir));
disp(['Saving in directory ' pwd '...']);
save(['itemwise_neural_' outtag '.mat'],'OUT','rois');

end %end function