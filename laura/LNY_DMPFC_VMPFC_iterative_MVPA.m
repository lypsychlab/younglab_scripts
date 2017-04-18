%jordan's mvpa stream
%Code by Drew Linsley
%Edited by Jordan Theriault, Emily Wasserman

%This macro needs toolbox settings to have matlab toolboxes above SPM.
%Otherwise the ttest function at the bottom will not work properly.

%Searchlight: What I'll need to do is set up a small mask, that iteratively
%moves around the volume. Shouldn't actually be too hard, but I don't know
%how to display the data after.
clear all
rmpath('/usr/public/spm/spm8/external/fieldtrip/src/');
%%%%%%%%%%%%%%%%%%%%%%INPUT%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
distance_metric = 'correlation'; %don't change. other options could be euclidean.
feature_selection = ''; %don't change.

input_id = {'YOU_STOR_01','YOU_STOR_02','YOU_STOR_03','YOU_STOR_04','YOU_STOR_05',...
'YOU_STOR_06','YOU_STOR_07','YOU_STOR_09','YOU_STOR_10','YOU_STOR_11','YOU_STOR_12', 'YOU_STOR_13', 'YOU_STOR_14',...
'YOU_STOR_15','YOU_STOR_TEST01'};
input_runs = {6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,6};
num_conds = 4;

study_path = '/home/younglw/lab/STOR/';
model_path = '/results/STOR_results_unsmoothednormed';
outputfolder = '/home/younglw/lab/STOR/STOR_MVPA';
outputname = 'allsubjects';

condition_names = {'A_RECIP','B_IMPART', 'C_GIVING', 'D_NEUTRAL'}; %These should match the order that they are listed in spm_input in the behavioural files.
roiFiles = {'DMPFC_tom_localizer_*03-Apr-2017','VMPFC_tom_localizer_*04-Apr-2017'}; %it will wildcard either side of this, so make sure
%that these uniquely identify a ROI. It is looking for an image file.
contrast_names = {'RECIP_v_IMPART', 'RECIP_v_GIVING', 'RECIP_v_NEUTRAL', 'IMPART_v_GIVING', 'IMPART_v_NEUTRAL', 'GIVING_v_NEUTRAL'};
contrast_nums = {[1 2; 1 3; 1 4; 2 3; 2 4; 3 4]};

FisherTransform = 'Y' %Transform correlation coefficents to follow normal distribution, using atanh().
preprocYN = 'Y' %this means preprocessing the BOLD data, either by centering voxels or runs.

%if you are preprocessing, one of these should be set to Y, and the other
%to N.
    preproc_voxelwise = 'N' %Y/N
    preproc_runwise = 'Y' %Y/N

%Same thing here, one should be Y, one should be no.
    preproc_zscore = 'N' %Y/N
    preproc_cocktail = 'Y' %Y/N This means just subtracting the mean, and not dividing by S.D.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %checking to make sure preprocessing done correctly.
    if strcmp('Y',preprocYN)'
        if or(and(strcmp('N',preproc_voxelwise), strcmp('N',preproc_runwise)), and(strcmp('Y',preproc_voxelwise), strcmp('Y',preproc_runwise)))
           error('You messed up the proprocessing orders. Fix them near the top of the script.')
        elseif or(and(strcmp('N',preproc_zscore), strcmp('N',preproc_cocktail)), and(strcmp('Y',preproc_zscore), strcmp('Y',preproc_cocktail)))
           error('You messed up the proprocessing orders. Fix them near the top of the script.')
        end
    end

    %creating the name based on preprocessing.
    if strcmp('N',preprocYN)
        preprocname = '_raw';
    else
        if strcmp('Y', preproc_voxelwise), preprocname = '_voxel';
        else preprocname = '_run';
        end
        if strcmp('Y', preproc_zscore), preprocname = [preprocname '_zscore'];
        else preprocname = [preprocname '_meancen'];
        end
    end
        
    
    
experiments=struct(...
    'name','STOR',... % study name you %%%%need to change this
    'pwd1','/home/younglw/lab/STOR/',...   % folder with participants %%%%need to change this
    'pwd2','/results/STOR_results_unsmoothednormed',...   % inside each participant, path to SPM.mat %%%%need to change this 
    'data',{input_id},...
    'participantRuns', {input_runs});

    if numel(experiments.data) ~= numel(experiments.participantRuns)
        error('list of run numbers and participants not equal. TRY AGAIN')
    end

contrasts=struct(...
    'name', {contrast_names},...
    'contrasts', contrast_nums);

results=struct('participants', struct('participant', experiments.data,...
    'ROI',struct(...
    'roiname', roiFiles,...
    'condition', struct('condname', condition_names),...
    'contrasts', struct('name',contrasts.name,...
    'voxels', zeros(1,1)))), 'ROI', struct('ROI', roiFiles, 'contrasts', struct('name',contrasts.name, 'acc', zeros(0,0)))); 

mask_perf = zeros(numel(experiments.data),numel(roiFiles));

for mm = 1:numel(experiments.data), %going through each participant here
%% Find Participant
    participantFiles = dir(fullfile(experiments.pwd1,experiments.data{mm},experiments.pwd2, 'beta*.img'));
        fprintf(sprintf('\r'))
        fprintf('~~~~~~~~~~~~~~~~~~~~%s~~~~~~~~~~~~~~~~~~~~', experiments.data{mm})
    num_runs = experiments.participantRuns{mm};
    if (numel(participantFiles)-num_runs)/num_runs ~= num_conds
        error('number of conditions and runs do not match beta files read. TRY AGAIN')
    end
    participantDir = fullfile(experiments.pwd1,experiments.data{mm},experiments.pwd2);
 



%% Collect Volumes
    cd(participantDir)
    
    head = spm_vol(participantFiles(1).name);
    beta_vols = zeros(head.dim(1),head.dim(2),head.dim(3),numel(participantFiles)); %collecting dimensions of brain scan.
        % Reads all beta images, enters them into beta_vols
        for nn = 1:numel(participantFiles),
            head = spm_vol(participantFiles(nn).name);
            beta_vols(:,:,:,nn) = spm_read_vols(head);
            
            if nn == 1,
                fprintf(sprintf('\r'))
            else
                fprintf(repmat(sprintf('\b'),1,numel(myStatus)));
            end
            myStatus = sprintf('Reading Beta Image #%i',nn);
            fprintf('%s',myStatus)
        end

%% Collect Masks        
    roiDir = fullfile(experiments.pwd1, experiments.data{mm}, '/roi/');
    cd(roiDir);
    
    maskFiles = cell(numel(roiFiles),1);
    for xx = 1:numel(roiFiles)
          if isempty(dir([experiments.pwd1  experiments.data{mm} '/roi/*' roiFiles{xx} '*.img']))
              fprintf(sprintf('\r'))
            fprintf('ROI: %s did not exist for participant %s', roiFiles{xx}, experiments.data{mm})
          else
             roi_file = dir([experiments.pwd1  experiments.data{mm} '/roi/*' roiFiles{xx} '*.img']);
%              maskFiles{xx} = spm_read_vols(spm_vol(roi_file.name));
               maskFiles{xx} = spm_read_vols(spm_vol(roi_file.name));
          end
    end
    
        %mask 4D vol
        masked_vols = cell(numel(maskFiles),1);
        for i = 1:numel(maskFiles),
            if sum(sum(sum(isnan(maskFiles{i})))) > 1
                maskFiles{i}(isnan(maskFiles{i})) = 0;
            end
                for j = 1:numel(beta_vols(1,1,1,:)), %mask by time, going through each beta
                    tScanVol = beta_vols(:,:,:,j);
                    masked_vols{i} = [masked_vols{i},tScanVol(logical(maskFiles{i}))];
                end
            if i == 1,
                fprintf(sprintf('\r'))
            else
                fprintf(repmat(sprintf('\b'),1,numel(myStatus)));
            end
            myStatus = sprintf('Creating Masked Volume #%i',i);
            fprintf('%s',myStatus)
        end
        

    
    %So by this point we've whittled down the full volumes of each contrast
    %to just the relevant voxels based on the mask. Each cell in masked
    %vols lists the voxels of the ROI in rows, then each contrast in
    %columns.
    
%% Create Results Structure for Participant

for nn=1:numel(roiFiles)
        for xx = 1:num_conds
            results.participants(mm).ROI(nn).condition(xx).correlations = zeros(1, (num_conds));
        end

        if ~isempty(masked_vols{nn})
            for xx = 1:numel(contrasts.contrasts(:,1))
                results.participants(mm).ROI(nn).contrasts(xx).acc = zeros(1, (4));;
                results.participants(mm).ROI(nn).contrasts(xx).final = zeros(1, 2);
            end
        end
end
    
    
    %% preprocess
    preproc_ind = reshape(repmat(1:num_runs,num_conds,1),1,num_runs*num_conds); %Identifies runs
        
    if strcmp('Y', preprocYN)
        for nn = 1:numel(masked_vols), %going through each mask
 
            if isempty(masked_vols{nn})==0
                
                this_vol = masked_vols{nn};
                    for oo = 1:(numel(preproc_ind)/num_conds), %going through each run.

%                         if strcmp('Y', preproc_voxelwise)
%                             for pp = 1:numel(this_vol(:,1)), %going through each voxel.
%                                 voxel_to_preprocess = this_vol(pp,ismembc(preproc_ind,oo));
%                                                 %So this is selecting each set of conditions belonging
%                                                 %to a run, for ONE voxel.
%                                 if strcmp('Y', preproc_zscore)
%                                     this_vol(pp,ismembc(preproc_ind,oo)) = zscore(voxel_to_preprocess); %zscore
%                                 elseif strcmp('Y', preproc_cocktail)
%                                     this_vol(pp,ismembc(preproc_ind,oo)) = voxel_to_preprocess - mean(voxel_to_preprocess); %cocktail
%                                 end
%                             end

                        if strcmp('Y', preproc_voxelwise)
                            for pp = 1:numel(this_vol(:,1)), %going through each voxel.
                                voxel_to_preprocess = this_vol(pp,ismembc(preproc_ind,oo));
                                                %So this is selecting each set of conditions belonging
                                                %to a run, for ONE voxel.
                                if strcmp('Y', preproc_zscore)
                                    vol_mean = nansum(nansum(voxel_to_preprocess))/numel(voxel_to_preprocess);
                                    this_vol(:,ismembc(preproc_ind,oo)) = (voxel_to_preprocess - vol_mean)/sqrt(nansum(nansum((voxel_to_preprocess - vol_mean).^2))/numel(voxel_to_preprocess)); 
                                elseif strcmp('Y', preproc_cocktail)
                                    this_vol(pp,ismembc(preproc_ind,oo)) = voxel_to_preprocess - nanmean(voxel_to_preprocess); %cocktail
                                end
                            end


                        elseif strcmp('Y', preproc_runwise)
                                voxel_to_preprocess = this_vol(:,ismembc(preproc_ind,oo));
                                                %So this is selecting each set of conditions belonging
                                                %to a run, for ONE voxel.
                                if strcmp('Y', preproc_zscore)
                                    vol_mean = nansum(nansum(voxel_to_preprocess))/numel(voxel_to_preprocess);
                                    this_vol(:,ismembc(preproc_ind,oo)) = (voxel_to_preprocess - vol_mean)/sqrt(nansum(nansum((voxel_to_preprocess - vol_mean).^2))/numel(voxel_to_preprocess)); %zscore
                                elseif strcmp('Y', preproc_cocktail)
                                    this_vol(:,ismembc(preproc_ind,oo)) = voxel_to_preprocess - nanmean(nanmean(voxel_to_preprocess)); %cocktail
                                end
                        end
                    end

                masked_vols{nn} = this_vol;
            end
            
            if nn == 1,
                fprintf(sprintf('\r'))
            else
                fprintf(repmat(sprintf('\b'),1,numel(myStatus)))
            end
            myStatus = sprintf('Preprocessed mask #%i',nn);
             fprintf('%s',myStatus)


        end
    else 
        fprintf('\rSkipping Preprocessing\r');
    end    
    %% feature selection
    %we can talk
    
    if strcmp(feature_selection,'ANOVA'),
        
        %1. iterate by masks
        %2. for each rows within mask,
        %3. this voxel = mask(i)
        %4. p(i,1) = anova1(this voxel, pre_proc_index (123123123123123123,'off')
        %5. p(i,2) = i;
        %6. p = sortrows(p,1);
        %7. p = p(p<0.05,1);
        %8. for j = 1:numel(p(:,1))
        %9. fs_mask(j,:) = mask(p(j,2),:);
        %10. end
        %11. mask(i) = fs_mask;
        %12. end
       
    else
        fprintf('\rSkipping Feature Selection\r');
    end
    
    %% distance measure/classification
    preproc_ind_fs = repmat(1:num_conds,1,num_runs); 
    tester_set = nchoosek(1:num_runs,(num_runs/2));

    for nn = 1:numel(masked_vols), %going through each mask
        this_vol = masked_vols{nn};
        %We might need to implement something here eventually. Mask sizes
        %will not be even across participants, and so we might need to
        %randomly select a subset that matches the smallest ROI.
        
        if ~isempty(masked_vols{nn}) %skip empty masks.
        
            for oo = 1:(numel(tester_set(:,1))/2); %going through each tester set. After it is halfway through they become repeats.
                training_set = setdiff(1:num_runs,tester_set(oo,:));

                tester_voxels = this_vol(:,ismembc(preproc_ind,tester_set(oo,:))); %chooses columns of current volume within tester set
                training_voxels = this_vol(:,ismembc(preproc_ind,training_set)); %chooses columns of current volumes within trainer set

                testmeaned_conditions = zeros(numel(tester_voxels(:,1)),num_conds); %was originally zeros(tester_voxels(:,1),num_conds), but was getting error so added numel
                trainmeaned_conditions = zeros(numel(tester_voxels(:,1)),num_conds);
                %going through each condition.
                for pp = 1:num_conds
                    testmeaned_conditions(:,pp) = nanmean(tester_voxels(:,ismember(preproc_ind_fs(1:numel(tester_voxels(1,:))),pp)),2);         
                    trainmeaned_conditions(:,pp) = nanmean(training_voxels(:,ismember(preproc_ind_fs(1:numel(training_voxels(1,:))),pp)),2);
                end

                %This loop populates results with all within condition
                %correlations, and all relevant between. No correlations
                %between conditions within a half are saved.
                for zz = 1:num_conds
                    if strcmp(distance_metric,'correlation'),
                        distance_matrix = 1 - pdist([testmeaned_conditions(~isnan(testmeaned_conditions(:,1)),zz)  trainmeaned_conditions(~isnan(trainmeaned_conditions(:,1)), :)]', 'correlation');
                    else
                        distance_matrix = pdist([testmeaned_conditions(~isnan(testmeaned_conditions(:,1)),zz)  trainmeaned_conditions(~isnan(trainmeaned_conditions(:,1)), :)]',distance_metric);
                    end
                    if strcmp(FisherTransform, 'Y')
                        distance_matrix = atanh(distance_matrix);
                    end
                    results.participants(mm).ROI(nn).condition(zz).correlations(oo,:) = distance_matrix(1:num_conds);
                end
            end %oo

            for zz = 1:numel(contrasts.contrasts(:,1)) 
                results.participants(mm).ROI(nn).contrasts(zz).raw(:,1)=results.participants(mm).ROI(nn).condition(contrasts.contrasts(zz,1)).correlations(:,contrasts.contrasts(zz,1)); %gets raw within for conditon 1
                results.participants(mm).ROI(nn).contrasts(zz).raw(:,2)=results.participants(mm).ROI(nn).condition(contrasts.contrasts(zz,2)).correlations(:,contrasts.contrasts(zz,2)); %gets raw within for conditon 2
                results.participants(mm).ROI(nn).contrasts(zz).raw(:,3)=results.participants(mm).ROI(nn).condition(contrasts.contrasts(zz,1)).correlations(:,contrasts.contrasts(zz,2)); %gets between correlation of condition #1 w condition #2
                results.participants(mm).ROI(nn).contrasts(zz).raw(:,4)=results.participants(mm).ROI(nn).condition(contrasts.contrasts(zz,2)).correlations(:,contrasts.contrasts(zz,1)); %gets between correlation of condition #2 w condition #1

                results.participants(mm).ROI(nn).contrasts(zz).within_cond1=results.participants(mm).ROI(nn).contrasts(zz).raw(:,1);
                results.participants(mm).ROI(nn).contrasts(zz).within_cond2=results.participants(mm).ROI(nn).contrasts(zz).raw(:,2);
                results.participants(mm).ROI(nn).contrasts(zz).between=results.participants(mm).ROI(nn).contrasts(zz).raw(:,3:4);

%                 performing the comparisons
%                   Doing all between comparisons, as I am here, makes no
%                   differnece. If you compared w1-b2 and w2-b1 only, you
%                  would get the same results.
                results.participants(mm).ROI(nn).contrasts(zz).total_correct=sum(sum(...
                    [results.participants(mm).ROI(nn).contrasts(zz).within_cond1(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,1),...
                    results.participants(mm).ROI(nn).contrasts(zz).within_cond2(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,1),...
                    results.participants(mm).ROI(nn).contrasts(zz).within_cond1(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,2),...
                    results.participants(mm).ROI(nn).contrasts(zz).within_cond2(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,2)]));
                results.participants(mm).ROI(nn).contrasts(zz).total_tests=numel(...
                    [results.participants(mm).ROI(nn).contrasts(zz).within_cond1(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,1),...
                    results.participants(mm).ROI(nn).contrasts(zz).within_cond2(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,1),...
                    results.participants(mm).ROI(nn).contrasts(zz).within_cond1(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,2),...
                    results.participants(mm).ROI(nn).contrasts(zz).within_cond2(:) > results.participants(mm).ROI(nn).contrasts(zz).between(:,2)]);
                results.participants(mm).ROI(nn).contrasts(zz).voxels = numel(this_vol(:,1));
                
                %moving proportion to analyze with other participants.
                results.ROI(nn).contrasts(zz).acc = [results.ROI(nn).contrasts(zz).acc; results.participants(mm).ROI(nn).contrasts(zz).total_correct/results.participants(mm).ROI(nn).contrasts(zz).total_tests];
%                 results.ROI(nn).contrasts(zz).mean_between
            end   %zz
            %assemble within correlations for each condition
            within_temp = zeros(1,num_conds);
            for oo = 1:num_conds
                within_temp(1,oo) = mean(results.participants(mm).ROI(nn).condition(oo).correlations(oo),1);
            end
            results.ROI(nn).within(mm,:) = within_temp;
        end    
    end %nn
    
    
end %mm

% results.output={};
%Non-parametric
for nn = 1:numel(masked_vols)
    results.output.p{1,nn+1}=roiFiles(nn);
    results.output.mean{1,nn+1}=roiFiles(nn);
    results.output.se{1,nn+1}=roiFiles(nn);
    for zz = 1:numel(contrasts.contrasts(:,2))
    [x,results.ROI(nn).contrasts(zz).p] = ttest(results.ROI(nn).contrasts(zz).acc,.5,.05,'right');
    results.output.p{zz+1,nn+1}=results.ROI(nn).contrasts(zz).p;
    results.output.mean{zz+1,nn+1}=mean(results.ROI(nn).contrasts(zz).acc);
    results.output.se{zz+1,nn+1}=std(results.ROI(nn).contrasts(zz).acc)/sqrt(numel(results.ROI(nn).contrasts(zz).acc));
    end
end

    
for zz = 1:numel(contrasts.contrasts(:,2))
    results.output.p{zz+1,1}=contrasts.name(zz);
    results.output.mean{zz+1,1}=contrasts.name(zz);
    results.output.se{zz+1,1}=contrasts.name(zz);
end

cd(outputfolder);
cell2csv(sprintf([outputname preprocname '_p' '.csv']), results.output.p,',','2010');
cell2csv(sprintf([outputname preprocname '_mean' '.csv']), results.output.mean,',','2010');
cell2csv(sprintf([outputname preprocname '_se' '.csv']), results.output.se,',','2010');
save([outputname preprocname '_results'], 'results')

%add a save for the matlab file of results, or else add more inclusive
%correlation info. Ideally both.