function roi_mvpa_leavetwo(study,sub_nums,resdir,thiscond,roiname,outfile)


base_dir    = fullfile('/home/younglw'); % Where the subjects' data is kept
results_dir = resdir;
mkdir(fullfile(base_dir,study,'MVPA'));

addpath(genpath('/usr/public/spm/spm12'));

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

average_performance_ex_mask=zeros(length(subj_dirs),1);


cd(fullfile(base_dir,study,'behavioural'));
load categories;
disp(['Training classifier ' categories(thiscond).name]);



for subj = 1:length(subj_dirs)
    disp(['Processing subject ' num2str(subj)]);

    
    % try
        

        cd(fullfile(base_dir,study,subj_dirs{subj},'results', resdir));
        load SPM.mat

        betadir = dir('beta_item*nii');betafiles=cell(60,1);
        for i=1:length(betafiles)
            betafiles{i} = betadir(i).name;
        end
        disp('Loading beta files...')
        subimg    = spm_vol([repmat([fullfile(base_dir,study,subj_dirs{subj},'results',[resdir '/'])],60,1) char(betafiles) repmat(',1',60,1)]); %spm_vol reads header info
        % keyboard
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
        
        for one_beta=1:60
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

        labels=cell(length(labeled_data),1);
        for thislab=1:length(labeled_data)
            if labeled_data(thislab)==0
                labels{thislab}=cnames{1};
            else
                labels{thislab}=cnames{2};
            end
        end
        


        [accuracy,sftscrs]=younglab_svm_leavetwo(spherebetas,labels,cnames,...
        fullfile(base_dir,study,'MVPA',[subj_dirs{subj} '.' outfile]));

                    
        average_performance_ex_mask(subj)= sftscrs;
        
        clear SPM.mat; clear accuracy sftscrs;
    % catch
    %     disp(['Unable to include subject ' num2str(subj)]);
    % end
end; %%% End of loop through subjects

% keyboard
[H,P,CI,STATS]=ttest(nonzeros(average_performance_ex_mask),0.5,0.05,'right');

cd(fullfile(base_dir,study,'MVPA'));
save(['average_performance_ex_mask_RTPJ_' outfile '.mat'],'average_performance_ex_mask','H','P','CI','STATS');
end %end function