clear classes; clear all;
experiments=struct(...
    'name','DIS_MVPA',... % study name
    'pwd1','/home/younglw/server/englewood/DIS_MVPA/DIS_MVPA/',...   % folder with participants
    'pwd2','results/DIS_results_smoothed_normed/',...   % inside each participant, path to SPM.mat
    'data',{{...
    'SAX_DIS_03','SAX_DIS_04','SAX_DIS_05','SAX_DIS_06','SAX_DIS_07',...
    'SAX_DIS_08','SAX_DIS_09','SAX_DIS_10','SAX_DIS_11','SAX_DIS_12',...
    'SAX_DIS_13','SAX_DIS_14','SAX_DIS_27','SAX_DIS_28','SAX_DIS_32',...
    'SAX_DIS_34','SAX_DIS_40','SAX_DIS_41','SAX_DIS_42','SAX_DIS_43',...
    'SAX_DIS_45','SAX_DIS_46'}});

partition_names     = {'Even ','Odd '};
condition_names_all = {{'accidental harm','intentional harm'}};
roin                = 'RTPJ';
roinum = 1;
savedirectory = ['/home/younglw/server/englewood/DIS_MVPA/DIS_MVPA/AlekEmily_replication/' roin];mkdir(savedirectory);


addpath(genpath('/usr/public/spm/spm8'));
spm fmri
addpath(genpath('/usr/public/conn')); % previously from /software/gablab/conn in saxelab
addpath(genpath('/home/younglw/scripts'));

for currentcond = 1:length(condition_names_all)
    condition_names = condition_names_all{currentcond};
    
    
    namestring = ['MVPA_' num2str(currentcond) '_' roin];
    filenameout=[namestring,'.csv'];
    cd(savedirectory)
    
    mask_name=''; % note: leave empty (mask_name='';) if you do not want to use subject-specific masks within each ROI
    mask_thr_type='FDR';
    mask_thr_value=.05;
    
    centering = 0;
    
    
    %roispath = directory;
    roiindexes=1;
        
    roinames{1}=roin;
    
    
    % options
    center=1;           % between-conditions centering (patterns are normalized to a mean of zero in each voxel across all conditions)
    collapserois=0;     % set to 1 to collapse across voxels from all ROIs or 0 to analyze voxels within each ROI separately
    minimumvoxels=2;   % spatial correlations across ROIs (after potential subject-specific masking) with less than minimumvoxels will not be computed (minimum value minimumvoxels=2)
    
    
    % locates appropriate subject-level files
    disp('locating appropriate subject-level files');
    spm_data=[];
    maskfilename={};
    if ~isempty(mask_name)
        if ischar(mask_name),
            for nsubject=1:numel(experiments.data),
                current_spm=fullfile(experiments.pwd1,experiments.data{nsubject},experiments.pwd2,'SPM.mat');
                [spm_data,SPM]=spm_ss_importspm(spm_data,current_spm);
                maskfilename{nsubject}=char(spm_ss_createlocalizermask({SPM},mask_name,[],0,mask_thr_type,mask_thr_value)); % subjects
            end
        else
            maskfilename=reshape(mask_name,[],1);
        end
    end
    datafilename={};
    if ~isempty(experiments)
        for nsubject=1:numel(experiments.data),
            fprintf(['now on subject ' num2str(nsubject) '\n']);
            current_spm=fullfile(experiments.pwd1,experiments.data{nsubject},experiments.pwd2,'SPM.mat');
            [spm_data,SPM]=spm_ss_importspm(spm_data,current_spm);
            Cnames={SPM.xCon(:).name};
            ic=[];ok=1;
            for n1=1:numel(partition_names),
                for n2=1:numel(condition_names),
                    temp=strmatch([partition_names{n1},condition_names{n2}],Cnames,'exact');if numel(temp)~=1,ok=0;break;else ic(n1,n2)=temp;end;
                    datafilename{nsubject,n1,n2}=fullfile(fileparts(current_spm),['con_',num2str(ic(n1,n2),'%04d'),'.img']); % subjects x partitions x conditions
                end
            end
            if ~ok, error(['contrast name ',[partition_names{n1},condition_names{n2}],' not found at ',current_spm]); end
        end
    end
    
    % Computes within-condition and between-condition spatial correlations
    % of effect sizes. Bivariate correlations are computed in both cases across
    % different data partitions (e.g. ODD vs. Edisp('computing spatial correlations');
        
    R=[];
    N=[];
    for nroi=1:numel(roinames),
        roi=roin;
        roinumber=1;
        
        if ~isempty(maskfilename)
            mask=rex(char(maskfilename),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0); % subjects x voxels mask
        end
        npartitionpair=0;
        for part1=1:numel(partition_names),
            for part2=[1:part1-1,part1+1:numel(partition_names)],
                npartitionpair=npartitionpair+1;
                
                % loads data
                for ncondition=1:numel(condition_names),
                    if ~isempty(datafilename)
                        
                        for s = 1:length(experiments.data) %for all subjects
                            thesubj = regexp(experiments.data{s},'/','split');
                            thesubj = thesubj{end};
                            
                            n = 1; %length(roi_file);
                            
                            % try
                                roi_file = dir([experiments.pwd1 experiments.data{s} '/roi/*' roin '*.img']);
                                roi  = fullfile(experiments.pwd1,experiments.data{s},'roi',roi_file(n).name);
                                roi
                                
                                Data_part1(ncondition).(thesubj) = rex(char({datafilename{s,part1,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0)'; % subjects x voxels data
                                Data_part2(ncondition).(thesubj) = rex(char({datafilename{s,part2,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0)'; % subjects x voxels data
                                
                            % catch
                            %     fprintf(['\n cannot find ' roi '\n']);
                            % end
                        end
                        
                    else
                        
                    end
                end
                % eliminates voxels with non-valid data (for any subject or condition)
                
                nsubjects = length(fieldnames(Data_part1));
                names     =        fieldnames(Data_part1);
                
                % gets rid of nans and centers (across conditions)
                for subj = 1:length(fieldnames(Data_part1))
                    
                    for n = 1:length(Data_part1)
                        Data_part1(n).(names{subj}) = Data_part1(n).(names{subj})(~isnan(Data_part1(n).(names{subj})));
                        Data_part2(n).(names{subj}) = Data_part2(n).(names{subj})(~isnan(Data_part2(n).(names{subj})));
                    end
                    
                    Raw_Data_part1 = Data_part1;  %uncentered data
                    Raw_Data_part2 = Data_part2;
                end
                
                % computes correlations - centered
                for nsubject=1:nsubjects,
                    idxvoxels=1:length(Data_part1(1).(names{nsubject}));
                    N(nsubject,npartitionpair,nroi)=numel(idxvoxels);
                    for ncondition1=1:numel(condition_names),
                        for ncondition2=1:numel(condition_names),
                            if numel(idxvoxels)>=minimumvoxels,
                                
                                % Spatial correlations: condition x condition x subjects x partitionpairs x rois
                                r = corrcoef([Data_part1(ncondition1).(names{nsubject}),Data_part2(ncondition2).(names{nsubject})]);r=r(1,2);
                                R(ncondition1,ncondition2,nsubject,npartitionpair,nroi) = r;
                            else
                                R(ncondition1,ncondition2,nsubject,npartitionpair,nroi)=nan;
                            end
                        end
                    end
                end
                
                %computes correlation - uncentered
                for nsubject=1:nsubjects,
                    idxvoxels=1:length(Raw_Data_part1(1).(names{nsubject}));
                    N(nsubject,npartitionpair,nroi)=numel(idxvoxels);
                    for ncondition1=1:numel(condition_names),
                        for ncondition2=1:numel(condition_names),
                            if numel(idxvoxels)>=minimumvoxels,
                                
                                % Spatial correlations: condition x condition x subjects x partitionpairs x rois
                                r=corrcoef([Raw_Data_part1(ncondition1).(names{nsubject}),Raw_Data_part2(ncondition2).(names{nsubject})]);r=r(1,2);
                                Rraw(ncondition1,ncondition2,nsubject,npartitionpair,nroi) = r;
                                
                            else
                                Rraw(ncondition1,ncondition2,nsubject,npartitionpair,nroi)=nan;
                            end
                            
                            for x = 1:length(condition_names)
                                for y = 1:length(condition_names{x})
                                    if condition_names{x}(y) == '-'
                                        condition_names{x}(y) = '_';
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    Z    = atanh(R);
    Zraw = atanh(Rraw);
    Z    = permute(Z,   [1,2,5,3,4]); % Spatial correlations (fisher transformed corr coefficients): condition(partition 1) x condition(partition 2) x rois x subjects x numberofpartitionpairs
    R    = permute(R,   [1,2,5,3,4]);
    Zraw = permute(Zraw,[1,2,5,3,4]); % Spatial correlations (fisher transformed corr coefficients): condition(partition 1) x condition(partition 2) x rois x subjects x numberofpartitionpairs
    Rraw = permute(Rraw,[1,2,5,3,4]);
    
    validsubjects=permute(all(N>1,2),[3,1,2]); % rois x subjects (invalid subjects are those where the subject-specific mask has one or zero voxels within the roi)
    rmpath(genpath('/usr/public/spm/spm8/external/fieldtrip/'));
    which nanmean

    % averaged across within conditions; averaged across between conditions
    Rraw_average = nanmean(nanmean(Rraw,5),4); Rraw_average(1,1,:,:,:) = nanmean(diag(nanmean(nanmean(Rraw,5),4))); Rraw_average(2,2,:,:,:) = nanmean(diag(nanmean(nanmean(Rraw,5),4)));
    R_average    = nanmean(nanmean(R,   5),4); R_average(   1,1,:,:,:) = nanmean(diag(nanmean(nanmean(R,   5),4))); R_average(   2,2,:,:,:) = nanmean(diag(nanmean(nanmean(R,   5),4)));
    Zraw_average = nanmean(nanmean(Zraw,5),4); Zraw_average(1,1,:,:,:) = nanmean(diag(nanmean(nanmean(Zraw,5),4))); Zraw_average(2,2,:,:,:) = nanmean(diag(nanmean(nanmean(Zraw,5),4)));
    Z_average    = nanmean(nanmean(Z,   5),4); Z_average(   1,1,:,:,:) = nanmean(diag(nanmean(nanmean(Z,   5),4))); Z_average(   2,2,:,:,:) = nanmean(diag(nanmean(nanmean(Z,   5),4)));
    
    % Computes correct classification (pairwise-comparisons: Table 1, Haxby et al.; and multiple-comparisons)
    disp('computing identification rates');
    
    if centering == 0
        acc_pairwise = zeros([size(Zraw,1),size(Zraw,2),size(Zraw,3),size(Zraw,4)]);% pairwise-conditions accuracy (within-condition correlation higher than ARBITRARY OTHER between-condition correlation, chance level 50%) for each subject (conditions x condition x rois x subjects)
        acc_all      = zeros([size(Zraw,1),size(Zraw,3),size(Zraw,4)]);% multiple-conditions accuracy (within-condition correlation higher than ALL OTHER between-condition correlations, chance level 100%/numberofconditions) for each subject (conditions x rois x subjects)
        for ncondition1=1:size(Zraw,1),
            for ncondition2=[1:ncondition1-1,ncondition1+1:size(Zraw,1)],
                acc_pairwise(ncondition1,ncondition2,:,:)= mean(mean([Zraw(ncondition1,ncondition1,:,:,:)-Zraw(ncondition1,ncondition2,:,:,:), Zraw(ncondition2,ncondition2,:,:,:)-Zraw(ncondition2,ncondition1,:,:,:)]), 5);  %changed from > to - for parametric
                acc_all(ncondition1,:,:)= shiftdim(mean( mean([all(Zraw(ncondition1,ncondition1*ones(1,size(Zraw,2)-1),:,:,:)-Zraw(ncondition1,[1:ncondition1-1,ncondition1+1:size(Zraw,2)],:,:,:),2),...
                    all(Zraw(ncondition2,ncondition2*ones(1,size(Zraw,2)-1),:,:,:)-Zraw(ncondition2,[1:ncondition2-1,ncondition2+1:size(Zraw,2)],:,:,:),2)]), 5),1);
            end
        end
    end
    
    if centering == 1
        acc_pairwise = zeros([size(Z,1),size(Z,2),size(Z,3),size(Z,4)]);% pairwise-conditions accuracy (within-condition correlation higher than ARBITRARY OTHER between-condition correlation, chance level 50%) for each subject (conditions x condition x rois x subjects)
        acc_all      = zeros([size(Z,1),size(Z,3),size(Z,4)]);% multiple-conditions accuracy (within-condition correlation higher than ALL OTHER between-condition correlations, chance level 100%/numberofconditions) for each subject (conditions x rois x subjects)
        for ncondition1=1:size(Z,1),
            for ncondition2=[1:ncondition1-1,ncondition1+1:size(Z,1)],
                acc_pairwise(ncondition1,ncondition2,:,:)= mean([Z(ncondition1,ncondition1,:,:,:)-Z(ncondition1,ncondition2,:,:,:), Z(ncondition2,ncondition2,:,:,:)-Z(ncondition2,ncondition1,:,:,:)], 5);  %changed from > to - for parametric
                acc_all(ncondition1,:,:)= shiftdim(mean( [all(Z(ncondition1,ncondition1*ones(1,size(Z,2)-1),:,:,:)-Z(ncondition1,[1:ncondition1-1,ncondition1+1:size(Z,2)],:,:,:),2),...
                    all(Z(ncondition2,ncondition2*ones(1,size(Z,2)-1),:,:,:)-Z(ncondition2,[1:ncondition2-1,ncondition2+1:size(Z,2)],:,:,:),2)], 5),1);
            end
        end
    end
    
    
    % total accuracy for each subject (conditions x rois x subjects)
    acc_total=permute(sum(acc_pairwise,2)/(size(acc_pairwise,2)-1),[1,3,4,2]);
    acc_total(:,find(~validsubjects))=nan;
    acc_all(  :,find(~validsubjects))=nan;
    
    
    fh=fopen(filenameout,'wt');
    
    %% pairwise
    
    %number of participants
    acc_n=sum(~isnan(acc_pairwise),4);
    %mean accuracy and stdev of participants
    acc_mean=nanmean(acc_pairwise,4);
    acc_stderr=nanstd(acc_pairwise,0,4)./sqrt(acc_n);
    chance_level=.0; %changed from .5 to 0 for parametric
   
    
    acc_T=(acc_mean-chance_level)./acc_stderr;
    acc_p=1-tcdf(acc_T,acc_n-1);
    acc_d = (acc_mean-chance_level)./nanstd(acc_pairwise,0,4);
    acc_r = (acc_T.^2)./((acc_T.^2+(acc_n-1)));
    
    
    pairwise.(genvarname([condition_names{1,:}])) = acc_pairwise;
    Rdata.(   genvarname([condition_names{1,:}])) = R;
    Zdata.(   genvarname([condition_names{1,:}])) = Z;
    Rrawdata.(genvarname([condition_names{1,:}])) = Rraw;
    Zrawdata.(genvarname([condition_names{1,:}])) = Zraw;
    
    
    save(['MVPA_data_' roin '.mat'],'pairwise','Rdata','Zdata','Zrawdata','Rrawdata','Data_part1','Data_part2')
    
    
    %% prints labels for pairwise
    fprintf(fh,'%s\n',['Accuracy of pairwise identification:    mean(standard error) p-value (chance level ',num2str(chance_level*100),'%)']);
    fprintf(fh,'%s','ROI,# of voxels,# of valid subjects');
    for n1=1:numel(condition_names),for n2=[1:n1-1,n1+1:numel(condition_names)],fprintf(fh,'%s',[',',condition_names{n1},' > ',condition_names{n2}]);end;end
    fprintf(fh,'\n');
    %prints values for pairwise
    for nroi=1:size(acc_mean,3),
        fprintf(fh,'%s',[roinames{nroi},',']);
        %mean and strror: num voxels
        fprintf(fh,'%s',[num2str(mean(mean(N(:,:,nroi),2),1),'%0.0f'),' (',num2str(std(mean(N(:,:,nroi),2),0,1)/sqrt(size(N,1)),'%0.0f'),'),']);
        %number of data points
        fprintf(fh,'%s',num2str(mean(mean(acc_n(:,:,nroi))),'%0.0f'));
        %mean, sterror, p value:  correlations
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',',num2str(acc_mean(n1,n2,nroi),'%0.3f'),'(',num2str(acc_stderr(n1,n2,nroi),'%0.3f'),') p=',num2str(acc_p(n1,n2,nroi),'%0.3f'), ' d=',num2str(acc_d(n1,n2,nroi),'%0.2f')]);end;end
        fprintf(fh,'\n ,,');
        %correlation values
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','Z-within (center) = ', num2str(Z_average(n1,n1),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','Z-across (center) = ', num2str(Z_average(n1,n2),'%0.3f')]);end;end
        fprintf(fh,'\n ,, ');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','Z-within (raw) = ', num2str(Zraw_average(n1,n1),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','Z-across (raw) = ', num2str(Zraw_average(n1,n2),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','R-within (center) = ',num2str(R_average(n1,n1),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','R-across (center) = ',num2str(R_average(n1,n2),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','R-within (raw) = ', num2str(Rraw_average(n1,n1),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1),for n2=[1:n1-1,n1+1:size(acc_mean,2)],fprintf(fh,'%s',[',','R-across (raw) = ',num2str(Rraw_average(n1,n2),'%0.3f')]);end;end
        fprintf(fh,'\n ,,');
        
    end
    fprintf(fh,'\n');
    
    
    % average
    acc_n=sum(~isnan(acc_total),3);
    acc_mean=nanmean(acc_total,3);
    acc_stderr=nanstd(acc_total,0,3)./sqrt(acc_n);
    chance_level=.0;  %changed
    acc_T=(acc_mean-chance_level)./acc_stderr;
    acc_p=1-tcdf(acc_T,acc_n-1);
    acc_d = (acc_mean-chance_level)./nanstd(acc_total,0,3);
    acc_r = (acc_T.^2)./((acc_T.^2+(acc_n-1)));
    
    A = (Rraw_average - diag(diag(Rraw_average))); Rraw_average_across = (sum(A)./sum(A~=0))';
    A = (R_average - diag(diag(R_average))); R_average_across = (sum(A)./sum(A~=0))';
    A = (Zraw_average - diag(diag(Zraw_average))); Zraw_average_across = (sum(A)./sum(A~=0))';
    A = (Z_average - diag(diag(Z_average))); Z_average_across = (sum(A)./sum(A~=0))';
    
    
    fprintf(fh,'%s\n',['Accuracy of identification (average):    mean(standard error) p-value (chance level ',num2str(chance_level),'%)']);
    fprintf(fh,'%s','ROI,# of voxels,# of valid subjects');
    for n1=1:numel(condition_names),fprintf(fh,'%s',[',',condition_names{n1}, ' > * (average)']);end
    fprintf(fh,'\n');
    for nroi=1:size(acc_mean,2),
        fprintf(fh, '%s',[roinames{nroi},',']);
        fprintf(fh,'%s',[num2str(mean(mean(N(:,:,nroi),2),1),'%0.0f'),' (',num2str(std(mean(N(:,:,nroi),2),0,1)/sqrt(size(N,1)),'%0.0f'),'),']);
        fprintf(fh,'%s',num2str(mean(acc_n(:,nroi)),'%0.0f'));
        for n1=1:size(acc_mean,1),fprintf(fh, '%s',[',',num2str(acc_mean(n1,nroi),'%0.3f'),'(',num2str(acc_stderr(n1,nroi),'%0.3f'),') p=',num2str(acc_p(n1,nroi),'%0.3f'), ' d=',num2str(acc_d(n1,nroi),'%0.2f')]);end
        fprintf(fh, '\n ,,');
        %correlation values
        for n1=1:size(acc_mean,1), fprintf(fh, '%s',[',','Z-within (center) = ', num2str(Z_average(n1,n1),'%0.3f')]);end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','Z-across (center) = ', num2str(Z_average_across(n1),'%0.3f')]);end
        fprintf(fh, '\n ,, ');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','Z-within (raw) = ', num2str(Zraw_average(n1,n1),'%0.3f')]);end
        fprintf(fh, '\n ,,');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','Z-across (raw) = ', num2str(Zraw_average_across(n1),'%0.3f')]);end
        fprintf(fh, '\n ,,');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','R-within (center) = ',num2str(R_average(n1,n1),'%0.3f')]);end
        fprintf(fh, '\n ,,');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','R-across (center) = ',num2str(R_average_across(n1),'%0.3f')]);end
        fprintf(fh,'\n ,,');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','R-within (raw) = ', num2str(Rraw_average(n1,n1),'%0.3f')]);end
        fprintf(fh, '\n ,,');
        for n1=1:size(acc_mean,1), fprintf(fh,'%s',[',','R-across (raw) = ',num2str(Rraw_average_across(n1),'%0.3f')]);end
        fprintf(fh, '\n ,,');
        
        
    end
    fprintf(fh,'\n');
    
end
