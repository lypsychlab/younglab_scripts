function roi_mvpa(study,sub_nums,resdir,thiscond,roiname,outfile)
% mat_file_name = 'zero_mean_TC_RTPJ.mat';% mat_file_name = name of TC .mat file
base_dir    = fullfile('/home/younglw',study); % Where the subjects' data is kept
results_dir = resdir;
mkdir(fullfile(base_dir,'MVPA'));


spm_get_defaults; warning off;
subj_dirs={};sessions={};
for thissub=1:length(sub_nums)
    subj_dirs{end+1}=sprintf('SAX_DIS_%02d',sub_nums(thissub));
end

for s=sub_nums
    if ismember(s,[5 9 16 19])
        sessions{end+1}=[10 12 14 20 22 24];
    elseif ismember(s,[7 14 24])
        sessions{end+1}=[12 14 16 22 24 26];
    elseif ismember(s,[37 44])
        sessions{end+1}=[6 8 10 16 18 20];
    elseif ismember(s,[38 39 40 42 45 46 47])
        sessions{end+1}=[4 6 8 14 16 18];
    elseif ismember(s,[17])
        sessions{end+1}=[8 12 14 20 22 24];
    elseif ismember(s,[41])
        sessions{end+1}=[4 8 10 16 18 20];
    elseif ismember(s,[32])
        sessions{end+1}=[8 10 12 20 22 24];
    else
        sessions{end+1}=[8 10 12 18 20 22];
    end
end
bolddirs_all=sessions;

average_performance_ex_mask=zeros(1,length(subj_dirs));


cd(fullfile(base_dir,'behavioural'));
load categories;
disp(['Training classifier ' categories(thiscond).name]);



for subj = 1:length(subj_dirs)
    disp(['Processing subject ' num2str(subj)]);

    
    try
        

        cd(fullfile(base_dir,study,subj_dirs{subj},'results', resdir));
        load SPM.mat

        betadir = dir('beta_item*nii');betafiles=cell(60,1);
        for i=1:length(betafiles)
            betafiles{i} = betadir(i).name;
        end
        disp('Loading beta files...')
        subimg    = spm_vol([repmat([fullfile(base_dir,study,subj_dirs{subj},'results',[resdir '/'])],60,1) char(betafiles) repmat(',1',60,1)]); %spm_vol reads header info
        [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes

        disp('Getting mask image...')
        prev_dir=pwd;
        cd(fullfile(base_dir,study,subj_dirs{subj},'roi'));
        roidir=dir(['ROI_' roiname '*img']);
        if isempty(roidir)
        disp(['No ' roiname ' for subject ' subj_dirs{subj} '; continuing to next subject']);
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

        disp(['Filling in mask...'])
        
        spherebetas = zeros(mask_length,60);
        
        for one_beta=1:conditions
            this_beta=Y(:,:,:,one_beta);
            for icoords = 1:mask_length % for each voxel
                spherebetas(icoords,one_beta) = this_beta(mask_inds(icoords));
            end
        end
        
        spherebetas=spherebetas';

        labeled_data=categories(thiscond).vals;

        keep_inds=find(~isnan(labeled_data));
        spherebetas=spherebetas(keep_inds,:);
        labeled_data=labeled_data(keep_inds);
        
        cnames=categories(thiscond).cnames;    


        accuracy=younglab_svm(spherebetas,labeled_data,cnames,...
        fullfile(base_dir,study,'SVM',[subj_dirs{subj} '.' outfile]));

                    
        average_performance_ex_mask(subj)= accuracy;
        
        clear SPM.mat; 
    catch
        disp(['Unable to include subject ' num2str(subj)]);
    end
end; %%% End of loop through subjects

[H,P,CI,STATS]=ttest(average_performance_ex_mask,0.5,0.05,'right')

cd(fullfile(base_dir,'MVPA'));
save(['average_performance_ex_mask_RTPJ_' outfile '.txt'],'average_performance_ex_mask','-ascii');
end %end function