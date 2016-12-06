function analyMVPA_general_nondirectional(roin, experiments,partition_names,condition_names_all,savedirectory,roinum, groups, group_loc,parametric)

% April 14 version -- Individual ROIs, parametric, 
% with contrast image creation 

%July 6 - generalized to add group ROISs

%Edited by Jorie Feb 2011 for saxelab 

%Edited by Lily Oct 2012 for younglab

spm fmri

addpath /software/spm8
addpath /software/conn % previously from /software/gablab/conn in saxelab
addpath /software/spm_ss

% .img files written 
images =1; 

% defines data sources
%   contrast files to consider for each subject are read from subject-specific SPM.mat files

for currentcond = 1:length(condition_names_all)
condition_names = condition_names_all{currentcond};
    
% for x = 1:length(condition_names)
%     for y = 1:length(condition_names{x})
%         if condition_names{x}(y) == '-'
%         condition_names{x}(y) = '_'
%         end
%     end
% end


namestring = ['MVPA_' num2str(currentcond) '_' roin];
filenameout=[namestring,'.csv'];
cd(savedirectory)

mask_name=''; % note: leave empty (mask_name='';) if you do not want to use subject-specific masks within each ROI
mask_thr_type='FDR';
mask_thr_value=.05;

centering = 0;
%parametric = 1;

%experiments=[];
%path_group='/groups/swjn/data/secondlevel_SWJN_SWJN_and_SWJNV2/'; 
%mask_name={maskfile_subject1,maskfile_subject2,etc.};

% % defines rois
% %   rois to consider are obtained from a partitioned ROI file (e.g. name: part###_*.img)
% roispath='/groups/swjn/data/secondlevel_SWJN_SWJN_and_SWJNV2/REST_S-N';
% roiindexes=[1,2,4,5,6,7,8];%[1,2,3,4,6,7,8,9,11,12,13,15,17,23,33,44];
% clear rois roinames roinumbers;for n1=1:length(roiindexes),
%     rois{n1}=fullfile(roispath,['part',num2str(roiindexes(n1),'%03d'),'_ps6ffspmT_0001.img']);
%     roinames{n1}=['ROI#',num2str(roiindexes(n1))];
%     roinumbers{n1}=[];
% end
%   rois to consider are obtained from a single ROI file possibly containing multiple ROIs (e.g. name: fROI.img)
%roispath='/mindhive/saxelab/roi_library/language_13_highest-overlap_partitions/';



%roispath = directory;
roiindexes=[1];
clear rois roinames roinumbers;
for n=1:length(roiindexes)
    rois{n}=roin;
    roinames{n}=[roin];
    roinumbers{n}=roiindexes(n);
end


% options
center=1;           % between-conditions centering (patterns are normalized to a mean of zero in each voxel across all conditions)
collapserois=0;     % set to 1 to collapse across voxels from all ROIs or 0 to analyze voxels within each ROI separately
minimumvoxels=2;   % spatial correlations across ROIs (after potential subject-specific masking) with less than minimumvoxels will not be computed (minimum value minimumvoxels=2)

measuretype=1;      % set to 1 to compute a correlation-based similarity measure between spatial patterns of responses (Haxby et al.)
                    % set to 2 to compute an unnormalized distance-based similarity measure between spatial patterns of responses (-log(distance)) 
                    % set to 3 to compute a normalized distance-based similarity measure between spatial patterns of responses (cosine similarity) 
                    
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

if collapserois,rois={char(rois)};end
%norig=[];n0=[];r_size=[];r_within=[];r_between=[];r_all=[];
R=[];
N=[];
for nroi=1:numel(rois),
    roi=rois{nroi};
    roinumber=roinumbers{nroi};
    %roi=''; % specify an ROI file for computing within-ROI spatial correlations, or leave this empty for computing whole-brain spatial correlations
%    if isempty(roi),
%        roi=fullfile(fileparts(which('spm')),'apriori','brainmask.nii');
%    end

    if ~isempty(maskfilename)
        mask=rex(char(maskfilename),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0); % subjects x voxels mask
    end
    npartitionpair=0;
    for part1=1:numel(partition_names),
        for part2=[1:part1-1,part1+1:numel(partition_names)],
            npartitionpair=npartitionpair+1;
            Data_part1=[];Data_part2=[];
            % loads data
            for ncondition=1:numel(condition_names),
                if ~isempty(datafilename)
                %    data_part1=rex(char({datafilename{:,part1,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0); % subjects x voxels data
                %   data_part2=rex(char({datafilename{:,part2,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0); % subjects x voxels data

                    for s = 1:length(experiments.data) %for all subjects 
                            thesubj = regexp(experiments.data{s},'/','split');
                            thesubj = thesubj{end};   

                            n = 1; %length(roi_file);    
                            
                           try
                               if groups ==0
                                   roi_file = dir([experiments.pwd1  experiments.data{s} '/roi/*' roin '*.img']);  
                                   roi = fullfile(experiments.pwd1,experiments.data{s},'roi',roi_file(n).name);
                               end
                              %  individual 
                          
                              if groups == 1
                                    roi_file = dir([group_loc '/*' roin '*.img']);
                                    roi = fullfile(group_loc,roi_file(n).name);
                              end      

                                data_part1(ncondition).(thesubj) = rex(char({datafilename{s,part1,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0)'; % subjects x voxels data
                                data_part2(ncondition).(thesubj) =  rex(char({datafilename{s,part2,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0)'; % subjects x voxels data           
%                                 nvox = size(data_part1(ncondition).(experiments.data{s}));
%                                 nvoxels.(experiments.(thesubj)) = nvox(1);

                           catch
                               fprintf(['\n cannot find ' experiments.pwd1 experiments.data{s} roi '\n']);
                           end
                           
                   end  
                
                else
    %                     file1=fullfile(path_group,[partition_names{part1},condition_names{ncondition}],'SPM.mat');
    %                     file2=fullfile(path_group,[partition_names{part2},condition_names{ncondition}],'SPM.mat');
    %                     if ~spm_existfile(file1), error(['file ',file1,' not found']); end
    %                     if ~spm_existfile(file2), error(['file ',file2,' not found']); end
    %                     data_part1=rex(file1,roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0); % subjects x voxels data
    %                     data_part2=rex(file2,roi,'level','voxels','select_clusters',0,'selected_clusters',roinumber,'disregard_zeros',0); % subjects x voxels data
                end
              %  if size(data_part1,1)~=size(data_part2,1), error(['Different number of subjects in ',file1,' and ',file2]); end
              %  if size(data_part1,2)~=size(data_part2,2), error(['Different number of voxels in ',file1,' and ',file2]); end
              %  Data_part1=cat(3,Data_part1,data_part1); % subjects x voxels x conditions data
              %  Data_part2=cat(3,Data_part2,data_part2); % subjects x voxels x conditions data
                 Data_part1 = data_part1;
                 Data_part2 = data_part2;
              
            end
            % eliminates voxels with non-valid data (for any subject or condition)
        
            nsubjects=length(fieldnames(Data_part1));
           
            names = fieldnames(Data_part1);

            % gets rid of nans and centers (across conditions)
              
                for subj = 1:length(fieldnames(Data_part1))
                        

                        for n = 1:length(Data_part1)
                                Data_part1(n).(names{subj}) = Data_part1(n).(names{subj})(~isnan(Data_part1(n).(names{subj})));
                                Data_part2(n).(names{subj}) = Data_part2(n).(names{subj})(~isnan(Data_part2(n).(names{subj})));
                        end
                        
                        Raw_Data_part1 = Data_part1;  %uncentered data
                        Raw_Data_part2 = Data_part2;
                        
%                         condmean1 = mean([Data_part1(1:length(Data_part1)).(names{subj})],2) ;
%                         condmean2 = mean([Data_part2(1:length(Data_part2)).(names{subj})],2)  ;  
%                          
%                         
%                          for n = 1:length(Data_part1)
%                              if length(Data_part1(n).(names{subj})) > 0
%                                 Data_part1(n).(names{subj})  = Data_part1(n).(names{subj}) - condmean1;
%                                 Data_part2(n).(names{subj}) = Data_part2(n).(names{subj}) - condmean2;
%                              end
%                          end
%                         
                end 
           
            
            % computes correlations - centered 
            for nsubject=1:nsubjects,
               idxvoxels=1:length(Data_part1(1).(names{nsubject})); 
               N(nsubject,npartitionpair,nroi)=numel(idxvoxels);
                for ncondition1=1:numel(condition_names),
                    for ncondition2=1:numel(condition_names),
                        if numel(idxvoxels)>=minimumvoxels,
                            if measuretype==1, r=corrcoef([Data_part1(ncondition1).(names{nsubject}),Data_part2(ncondition2).(names{nsubject})]);r=r(1,2);      % Spatial correlations: condition x condition x subjects x partitionpairs x rois
                            elseif measuretype==2, r=mean(abs(Data_part1(nsubject,idxvoxels,ncondition1)'-Data_part2(nsubject,idxvoxels,ncondition2)').^2,1);       % Spatial distance: condition x condition x subjects x partitionpairs x rois
                            elseif measuretype==3, r=(Data_part1(nsubject,idxvoxels,ncondition1)*Data_part2(nsubject,idxvoxels,ncondition2)')/sqrt(sum(abs(Data_part1(nsubject,idxvoxels,ncondition1)').^2,1))/sqrt(sum(abs(Data_part2(nsubject,idxvoxels,ncondition2)').^2,1)); 
                            end   % Spatial distance: condition x condition x subjects x partitionpairs x rois
                        
                           R(ncondition1,ncondition2,nsubject,npartitionpair,nroi)=r;  
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
                            if measuretype==1, r=corrcoef([Raw_Data_part1(ncondition1).(names{nsubject}),Raw_Data_part2(ncondition2).(names{nsubject})]);r=r(1,2);      % Spatial correlations: condition x condition x subjects x partitionpairs x rois
                            elseif measuretype==2, r=mean(abs(Raw_Data_part1(nsubject,idxvoxels,ncondition1)'-Raw_Data_part2(nsubject,idxvoxels,ncondition2)').^2,1);       % Spatial distance: condition x condition x subjects x partitionpairs x rois
                            elseif measuretype==3, r=(Raw_Data_part1(nsubject,idxvoxels,ncondition1)*Raw_Data_part2(nsubject,idxvoxels,ncondition2)')/sqrt(sum(abs(Raw_Data_part1(nsubject,idxvoxels,ncondition1)').^2,1))/sqrt(sum(abs(Raw_Data_part2(nsubject,idxvoxels,ncondition2)').^2,1)); 
                            end   % Spatial distance: condition x condition x subjects x partitionpairs x rois
                        
                           Rraw(ncondition1,ncondition2,nsubject,npartitionpair,nroi)=r;  
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
                        
                        if roinum == 1
                            if images ==1
                            %make image for associated pair 
                            vol1 = char({datafilename{nsubject,part1,ncondition1}});
                            vol2 = char({datafilename{nsubject,part2,ncondition2}});

                            vols = [vol1; vol2];
                            vols = spm_vol(vols); % spm function for volume information

                            f = 'i1 - (i1+i2)/2'; % define the operation as a string

                            fname = ['subj' num2str(nsubject) '_' condition_names{ncondition1} '_' condition_names{ncondition2} '.img'];

                            cd MVPA_images
                            Vo = struct('fname',fname,'dim',vols(1).dim(1:3),'dt',[spm_type('float32'),1],'mat',vols(1).mat,'descrip','imcalc test for jorie','mask',1); % define output structure
                            spm_imcalc(vols,Vo,f);
                            cd ..
                         end
                        end
                        
                    end
                end
            end    
      
          
        end
    end
end
if measuretype==1, Z=atanh(R); elseif measuretype==2,  Z=-log10(R); elseif measuretype==3,  Z=atanh(R); end
if measuretype==1, Zraw=atanh(Rraw); elseif measuretype==2,  Zraw=-log10(Rraw); elseif measuretype==3,  Zraw=atanh(Rraw); end

Z=permute(Z,[1,2,5,3,4]); % Spatial correlations (fisher transformed corr coefficients): condition(partition 1) x condition(partition 2) x rois x subjects x numberofpartitionpairs
R=permute(R,[1,2,5,3,4]);

Zraw=permute(Zraw,[1,2,5,3,4]); % Spatial correlations (fisher transformed corr coefficients): condition(partition 1) x condition(partition 2) x rois x subjects x numberofpartitionpairs
Rraw=permute(Rraw,[1,2,5,3,4]);

validsubjects=permute(all(N>1,2),[3,1,2]); % rois x subjects (invalid subjects are those where the subject-specific mask has one or zero voxels within the roi) 

% averaged across within conditions; averaged across between conditions
Rraw_average = nanmean(nanmean(Rraw,5),4); Rraw_average(1,1,:,:,:) = nanmean(diag(nanmean(nanmean(Rraw,5),4))); Rraw_average(2,2,:,:,:) = nanmean(diag(nanmean(nanmean(Rraw,5),4)));
R_average = nanmean(nanmean(R,5),4); R_average(1,1,:,:,:) = nanmean(diag(nanmean(nanmean(R,5),4))); R_average(2,2,:,:,:) = nanmean(diag(nanmean(nanmean(R,5),4)));

Zraw_average = nanmean(nanmean(Zraw,5),4); Zraw_average(1,1,:,:,:) = nanmean(diag(nanmean(nanmean(Zraw,5),4))); Zraw_average(2,2,:,:,:) = nanmean(diag(nanmean(nanmean(Zraw,5),4)));
Z_average = nanmean(nanmean(Z,5),4); Z_average(1,1,:,:,:) = nanmean(diag(nanmean(nanmean(Z,5),4))); Z_average(2,2,:,:,:) = nanmean(diag(nanmean(nanmean(Z,5),4)));

% Computes correct classification (pairwise-comparisons: Table 1, Haxby et al.; and multiple-comparisons)
disp('computing identification rates');  

if centering == 0
    acc_pairwise=zeros([size(Zraw,1),size(Zraw,2),size(Zraw,3),size(Zraw,4)]);% pairwise-conditions accuracy (within-condition correlation higher than ARBITRARY OTHER between-condition correlation, chance level 50%) for each subject (conditions x condition x rois x subjects)
    acc_all=zeros([size(Zraw,1),size(Zraw,3),size(Zraw,4)]);% multiple-conditions accuracy (within-condition correlation higher than ALL OTHER between-condition correlations, chance level 100%/numberofconditions) for each subject (conditions x rois x subjects)
    for ncondition1=1:size(Zraw,1),
        for ncondition2=[1:ncondition1-1,ncondition1+1:size(Zraw,1)],
            if parametric == 1
                acc_pairwise(ncondition1,ncondition2,:,:)= mean(mean([Zraw(ncondition1,ncondition1,:,:,:)-Zraw(ncondition1,ncondition2,:,:,:), Zraw(ncondition2,ncondition2,:,:,:)-Zraw(ncondition2,ncondition1,:,:,:)]), 5);  %changed from > to - for parametric
                acc_all(ncondition1,:,:)= shiftdim(mean( mean([all(Zraw(ncondition1,ncondition1*ones(1,size(Zraw,2)-1),:,:,:)-Zraw(ncondition1,[1:ncondition1-1,ncondition1+1:size(Zraw,2)],:,:,:),2),...
                    all(Zraw(ncondition2,ncondition2*ones(1,size(Zraw,2)-1),:,:,:)-Zraw(ncondition2,[1:ncondition2-1,ncondition2+1:size(Zraw,2)],:,:,:),2)]), 5),1);
            elseif parametric == 0
                acc_pairwise(ncondition1,ncondition2,:,:)= mean(mean([Zraw(ncondition1,ncondition1,:,:,:)>Zraw(ncondition1,ncondition2,:,:,:), Zraw(ncondition2,ncondition2,:,:,:)>Zraw(ncondition2,ncondition1,:,:,:)]), 5);  %changed from > to - for parametric
                acc_all(ncondition1,:,:)= shiftdim(mean( mean([all(Zraw(ncondition1,ncondition1*ones(1,size(Zraw,2)-1),:,:,:)>Zraw(ncondition1,[1:ncondition1-1,ncondition1+1:size(Zraw,2)],:,:,:),2),...
                    all(Zraw(ncondition2,ncondition2*ones(1,size(Zraw,2)-1),:,:,:)>Zraw(ncondition2,[1:ncondition2-1,ncondition2+1:size(Zraw,2)],:,:,:),2)]), 5),1);
            end
        end
    end
end

if centering == 1
    acc_pairwise=zeros([size(Z,1),size(Z,2),size(Z,3),size(Z,4)]);% pairwise-conditions accuracy (within-condition correlation higher than ARBITRARY OTHER between-condition correlation, chance level 50%) for each subject (conditions x condition x rois x subjects)
    acc_all=zeros([size(Z,1),size(Z,3),size(Z,4)]);% multiple-conditions accuracy (within-condition correlation higher than ALL OTHER between-condition correlations, chance level 100%/numberofconditions) for each subject (conditions x rois x subjects)
    for ncondition1=1:size(Z,1),
        for ncondition2=[1:ncondition1-1,ncondition1+1:size(Z,1)],
            if parametric == 1
                acc_pairwise(ncondition1,ncondition2,:,:)= mean([Z(ncondition1,ncondition1,:,:,:)-Z(ncondition1,ncondition2,:,:,:), Z(ncondition2,ncondition2,:,:,:)-Z(ncondition2,ncondition1,:,:,:)], 5);  %changed from > to - for parametric
                acc_all(ncondition1,:,:)= shiftdim(mean( [all(Z(ncondition1,ncondition1*ones(1,size(Z,2)-1),:,:,:)-Z(ncondition1,[1:ncondition1-1,ncondition1+1:size(Z,2)],:,:,:),2),...
                    all(Z(ncondition2,ncondition2*ones(1,size(Z,2)-1),:,:,:)-Z(ncondition2,[1:ncondition2-1,ncondition2+1:size(Z,2)],:,:,:),2)], 5),1);
            elseif parametric == 0
                acc_pairwise(ncondition1,ncondition2,:,:)= mean([Z(ncondition1,ncondition1,:,:,:)>Z(ncondition1,ncondition2,:,:,:), Z(ncondition2,ncondition2,:,:,:)>Z(ncondition2,ncondition1,:,:,:)], 5);  %changed from > to - for parametric
                acc_all(ncondition1,:,:)= shiftdim(mean( [all(Z(ncondition1,ncondition1*ones(1,size(Z,2)-1),:,:,:)>Z(ncondition1,[1:ncondition1-1,ncondition1+1:size(Z,2)],:,:,:),2),...
                    all(Z(ncondition2,ncondition2*ones(1,size(Z,2)-1),:,:,:)>Z(ncondition2,[1:ncondition2-1,ncondition2+1:size(Z,2)],:,:,:),2)], 5),1);
            end
        end
    end
end 


% total accuracy for each subject (conditions x rois x subjects)
acc_total=permute(sum(acc_pairwise,2)/(size(acc_pairwise,2)-1),[1,3,4,2]);
acc_total(:,find(~validsubjects))=nan;
acc_all(:,find(~validsubjects))=nan;

%acc_pairwise 
    %all single pairwise differences for within and across (ArA- ArB; BrB - BrA)
    %averages across-comparisions:  e.g. Aodd r Beven and Aeven r Bodd
%acc_total = average accuracy for all conditions 
    %average of all comparisions for given condtion:  e.g. avg(ArA-ArB & ArA-ArC)
%acc_all     
    %possiby same as acc_total 
    
fh=fopen(filenameout,'wt');

%% pairwise

%number of participants
acc_n=sum(~isnan(acc_pairwise),4);
%mean accuracy and stdev of participants 
acc_mean=nanmean(acc_pairwise,4);
acc_stderr=nanstd(acc_pairwise,4,0)./sqrt(acc_n); 

if parametric == 1
    chance_level=.0; %changed from .5 to 0 for parametric 
elseif parametric == 0
    chance_level=.5; %changed from .5 to 0 for parametric 
end




acc_T=(acc_mean-chance_level)./acc_stderr;
acc_p=1-tcdf(acc_T,acc_n-1);
acc_d = (acc_mean-chance_level)./nanstd(acc_pairwise,4,0);
acc_r = (acc_T.^2)./((acc_T.^2+(acc_n-1)));


pairwise.(genvarname([condition_names{1,:}])) = acc_pairwise;
Rdata.(genvarname([condition_names{1,:}])) = R;
Zdata.(genvarname([condition_names{1,:}])) = Z;
Rrawdata.(genvarname([condition_names{1,:}])) = Rraw;
Zrawdata.(genvarname([condition_names{1,:}])) = Zraw;


save(['MVPA_data_' roin '.mat'],'pairwise','Rdata','Zdata','Zrawdata','Rrawdata','Data_part1','Data_part2')

%prints labels for pairwise
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
    fprintf(fh,'%s',[num2str(mean(mean(acc_n(:,:,nroi))),'%0.0f')]);
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


%% average 
acc_n=sum(~isnan(acc_total),3);
acc_mean=nanmean(acc_total,3);
acc_stderr=nanstd(acc_total,3,0)./sqrt(acc_n);
chance_level=.0;  %changed 
acc_T=(acc_mean-chance_level)./acc_stderr;
acc_p=1-tcdf(acc_T,acc_n-1);
acc_d = (acc_mean-chance_level)./nanstd(acc_total,3,0);
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
    fprintf(fh,'%s',[num2str(mean(acc_n(:,nroi)),'%0.0f')]);
    for n1=1:size(acc_mean,1),fprintf(fh, '%s',[',',num2str(acc_mean(n1,nroi),'%0.3f'),'(',num2str(acc_stderr(n1,nroi),'%0.3f'),') p=',num2str(acc_p(n1,nroi),'%0.3f'), ' d=',num2str(acc_d(n1,nroi),'%0.2f')]);end
    fprintf(fh, '\n ,,');
    %correlation values
    for n1=1:size(acc_mean,1) fprintf(fh, '%s',[',','Z-within (center) = ', num2str(Z_average(n1,n1),'%0.3f')]);end
    fprintf(fh,'\n ,,');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','Z-across (center) = ', num2str(Z_average_across(n1),'%0.3f')]);end
    fprintf(fh, '\n ,, ');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','Z-within (raw) = ', num2str(Zraw_average(n1,n1),'%0.3f')]);end
    fprintf(fh, '\n ,,');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','Z-across (raw) = ', num2str(Zraw_average_across(n1),'%0.3f')]);end
    fprintf(fh, '\n ,,');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','R-within (center) = ',num2str(R_average(n1,n1),'%0.3f')]);end
    fprintf(fh, '\n ,,');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','R-across (center) = ',num2str(R_average_across(n1),'%0.3f')]);end
    fprintf(fh,'\n ,,');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','R-within (raw) = ', num2str(Rraw_average(n1,n1),'%0.3f')]);end
    fprintf(fh, '\n ,,');
    for n1=1:size(acc_mean,1) fprintf(fh,'%s',[',','R-across (raw) = ',num2str(Rraw_average_across(n1),'%0.3f')]);end
    fprintf(fh, '\n ,,');

   
end
fprintf(fh,'\n');

%% total
% acc_n=sum(~isnan(acc_all),3);
% acc_mean=nanmean(acc_all,3);
% acc_stderr=nanstd(acc_all,0,3)./sqrt(acc_n);
% chance_level=1/size(Z,2);
% acc_T=(acc_mean-chance_level)./acc_stderr;
% acc_p=1-tcdf(acc_T,acc_n-1);
% fprintf(fh,'%s\n',['Accuracy of identification (across all conditions):    mean(standard error) p-value (chance level ',num2str(chance_level*100),'%)']);
% fprintf(fh,'%s','ROI,# of voxels,# of valid subjects');
% for n1=1:numel(condition_names),fprintf(fh,'%s',[',',condition_names{n1},' > * (all)']);end
% fprintf(fh,'\n');
% for nroi=1:size(acc_mean,2),
%     fprintf(fh,'%s',[roinames{nroi},',']);
%     fprintf(fh,'%s',[num2str(mean(mean(N(:,:,nroi),2),1),'%0.0f'),' (',num2str(std(mean(N(:,:,nroi),2),0,1)/sqrt(size(N,1)),'%0.0f'),'),']);
%     fprintf(fh,'%s',[num2str(mean(acc_n(:,nroi)),'%0.0f')]);
%     for n1=1:size(acc_mean,1),fprintf(fh,'%s',[',',num2str(100*acc_mean(n1,nroi),'%0.0f'),'(',num2str(100*acc_stderr(n1,nroi),'%0.1f'),') p=',num2str(acc_p(n1,nroi),'%0.3f')]);end
%     fprintf(fh,'\n');
% end
% fprintf(fh,'\n');


%% plots 

fclose(fh);
disp(['Accuracy output stored in ',filenameout,'.']);

% Creates plots (figure 4, Haxby et al.)
disp('displaying plots');

Z_n=sum(~isnan(mean(Z,5)),4);
Z_mean=nanmean(mean(Z,5),4);
Z_stderr=nanstd(mean(Z,5),4,0)./sqrt(Z_n); 
nrois=1:size(Z_mean,3);

% figure('color','w');
% for ncondition=1:size(Z_mean,1), % conditions
%     subplot(size(Z_mean,1)+1,1,ncondition);hold on;
%     z=shiftdim(Z_mean(ncondition,:,nrois),1);
%     e=shiftdim(Z_stderr(ncondition,:,nrois),1);
%     h1=bar(z);
%     ztemp=z;ztemp(ncondition,:)=0;
%     h2=bar(ztemp);
%     xdata=[];
%     for nroi=1:numel(h1), set(h1(nroi),'facecolor',[1,0,0]*nroi/numel(h1)); temp=get(get(h1(nroi),'children'),'xdata'); xdata(:,nroi)=mean(temp,1)'; end
%     for nroi=1:numel(h2), set(h2(nroi),'facecolor',[0,0,1]*nroi/numel(h2)); end
%     errorbar(xdata,z,e,'k.');
%     hold off;
%     axis tight;
%     set(gca,'xlim',[0,size(Z_mean,2)+1],'xcolor','w');
%     ylabel(condition_names{ncondition});
% end
% set(gca,'xcolor','k','xtick',1:numel(condition_names),'xticklabel',condition_names);
% subplot(size(Z_mean,1)+1,3,size(Z_mean,1)*3+2);
% c0=permute([1,0,0;0,0,1],[1,3,2]);c=[];
% for nroi=1:size(Z_mean,3),c(:,nroi,:)=c0(:,1,:)*nroi/size(Z_mean,3); end
% image(c);axis equal; axis tight;
% ht=text(1:numel(roinames),size(c,1)+ones(1,numel(roinames)),roinames);set(ht,'rotation',-90);
% if measuretype==1, set(gca,'xtick',[],'ytick',1:2,'yticklabel',{'Within-condition correlations','Between-condition correlations'},'yaxislocation','right');
% elseif measuretype==2, set(gca,'xtick',[],'ytick',1:2,'yticklabel',{'Within-condition similarity','Between-condition similarity'},'yaxislocation','right'); 
% elseif measuretype==3, set(gca,'xtick',[],'ytick',1:2,'yticklabel',{'Within-condition similarity','Between-condition similarity'},'yaxislocation','right'); end

clear condition_names;
clear datafilename
clear data_part1
clear data_part2
clear R
clear Rraw
clear Z
clear Zraw

end
x=5
end
