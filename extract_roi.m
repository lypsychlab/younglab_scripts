function extract_roi(sub_nums)
% mask_image_name = name of mask image (e.g., 'ROI_RTPJ_tom_localizer*img')
% mat_file_name = name of output .mat file (e.g., 'zero_meaned_TC_RTPJ_wraf.mat')

% Extracts timecourse information or beta values for specified subjects
% Output gets saved as a .mat in the model directory in the
% results folder (model should use unsmoothed data)

% User input required here:
mask_image_name = 'ROI_RTPJ*img';
mat_file_name   = 'zero_mean_TC_RTPJ';

addpath(genpath('/home/younglw/lab/VERBS'));

base_dir = '/home/younglw/lab/VERBS/'; % where the subjects' data are kept
results_dir = 'DIS_results_itemwise_concat_normed'; % name of your results folder

% i=1;
% for num=[3:10 12:14 27 28 32 34 38 40:43 45 46]
%     if num<10
% 	    subj_dirs{i} = ['SAX_DIS_0' num2str(num)];
%     else
%         subj_dirs{i} = ['SAX_DIS_' num2str(num)];
%     end
% 	i=i+1;
% end

subj_dirs={};
for thissub=1:length(sub_nums)
    subj_dirs{end+1}=sprintf('SAX_DIS_%02d',sub_nums(thissub));
end

num_TC_total = 166*6; % enter TOTAL ips
ips=166;

% choose one of these options:
% (1) 'beta': beta images
% (2) 'raf': realigned but unsmoothed and unnormed functional images
% (3) 'wraf': realigned and normed but unsmoothed functional images
% (4) 'swraf': realigned, normed, and smoothed functional images
% *** you should never use smoothed data for MVPA ***
% Recommended:
% searchlight MVPA: 'raf'
% ROI-based MVPA: 'wraf'
file_type = 'wraf';

% enter name of mask image
% note: automatically chooses the most recent one (if there are multiple ROI files of the same type)
% mask_image_name = 'ROI_RTPJ_tom_localizer*.img';

% enter name of the output .mat file (it should make sense depending on
% your choices above)
%
% some examples:
% 'zero_meaned_TC_whole_brain_raf.mat';
% 'zero_meaned_TC_RTPJ_wraf.mat';
% 'zero_meaned_betas_total.mat'
% mat_file_name = 'zero_meaned_TC_RTPJ_wraf.mat';

% enter run numbers for each subject that you're planning on running the analysis on
sessions={};
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

spm_defaults_lily;

num_subjs = length(sub_nums);

for subj_num =1:num_subjs,
    
    disp(['extracting time-courses for subject ' subj_dirs{subj_num} ]);
    
    this_subj_base_dir = [ base_dir subj_dirs{subj_num}  ];
    
    % for functional runs only
    this_subj_functional_dir = [ this_subj_base_dir '/bold/' ];
    
    this_subj_GLM_dir = [ this_subj_base_dir '/results/' results_dir ]; % name of the results folder
    
    % try
    %     if exist(mask_image_name,'file')
    %         info = dir(mask_image_name);
    %         Vmask_name = info.name;
    %         cd('/home/younglw/RACA/RACA_ROI_MVPA') % only if the mask is in this directory
    %     else
            mask_dir = [this_subj_base_dir '/roi/']; % if doing whole-brain, this should be the same as this_subj_GLM_dir
            cd (mask_dir);
            Vmask_names = dir(mask_image_name);
            
            if ~isempty(Vmask_names)
                % chooses the most recent mask
                Vmask_name = Vmask_names(1).name;
                for mask_num=1:length(Vmask_names)
                    if Vmask_names(mask_num).datenum > Vmask_name
                        Vmask_name = Vmask_names(mask_num).name;
                    end
                end
            end
        % end
        
        bolddirs = bolddirs_all{subj_num};
        num_runs = length(bolddirs);
        
        % Extracts time course information from a specified model
        warning off
        
        %%%% Only do the calculation for voxels in the mask image
        
        Vmask = spm_vol(Vmask_name);
        mask_matrix = spm_read_vols(Vmask);
        mask_inds = find(mask_matrix);     %%% The indices of where mask=1
        num_mask_voxels = length(mask_inds);
        
        [x_in_mask,y_in_mask,z_in_mask]=ind2sub(size(mask_matrix),mask_inds);
        
        %%% XYZ has three rows, and one col for every voxel in the mask
        XYZ = [x_in_mask,y_in_mask,z_in_mask]';
        
        cd(this_subj_GLM_dir);
        load SPM.mat
        
        % zero_meaned_TC_total=zeros (num_TC_total*num_runs,num_mask_voxels); % for ROI-based MVPA
        zero_meaned_TC_total=zeros (num_TC_total,num_mask_voxels); % for ROI-based MVPA
        %dimensions: total intervals (166*6) x number of voxels in mask

        % zero_meaned_TC_total=zeros(num_TC_total,num_mask_voxels,num_runs); % for searchlight (verify)
        
        TC_matrix=zeros(size(mask_matrix,1), size(mask_matrix,2), size(mask_matrix,3),num_TC_total);
        all_imfiles=[];all_dirpath=[];
        for sess_num = 1:num_runs,
            
            disp(['Run: ' num2str(sess_num) ]);
            
            % directory name with bold images
            % if bolddirs(sess_num) < 10
            %     dirname = [this_subj_functional_dir '00' num2str(bolddirs(sess_num)) '/'];
            % else
            %     dirname = [this_subj_functional_dir '0' num2str(bolddirs(sess_num)) '/'];
            % end

            dirname=[this_subj_functional_dir sprintf('%03d',bolddirs(sess_num)) '/'];
            
            % specify type of image
            if strcmp(file_type,'beta')
                image_filenames_without_dir_path = spm_select('List',dirname,'^beta.*.img');
            elseif strcmp(file_type,'raf')
                image_filenames_without_dir_path = spm_select('List',dirname,['^raf0-00.*' num2str(bolddirs(sess_num)) '-.*.-.*.-*.img']);
            elseif strcmp(file_type,'wraf')
                image_filenames_without_dir_path = spm_select('List',dirname,['^wraf0-00.*' num2str(bolddirs(sess_num)) '-.*.-.*.-*.img']);
            elseif strcmp(file_type,'swraf')
                image_filenames_without_dir_path = spm_select('List',dirname,['^swraf0-00.*' num2str(bolddirs(sess_num)) '-.*.-.*.-*.img']);
            end
            
           % image_filenames_without_dir_path = spm_select('List',dirname,['^swrf0-00.*' num2str(bolddirs(sess_num)) '-.*.-.*.-*.img']);
           all_imfiles=[all_imfiles; image_filenames_without_dir_path];
            
            % truncate in case too many files (i.e., when the scan was stopped much later than it should've)
            % if length(image_filenames_without_dir_path) > num_TC_total
            %     image_filenames_without_dir_path = image_filenames_without_dir_path(1:num_TC_total,:);
            % end
            
            % copies_of_directory_path = repmat(dirname,num_TC_total,1);
            copies_of_directory_path = repmat(dirname,ips,1);
            all_dirpath=[all_dirpath; copies_of_directory_path];
        end

            image_filenames_with_path = [all_dirpath all_imfiles];
            unfiltered_TC = spm_get_data(image_filenames_with_path,XYZ); %concatenated

            
            % this part gets funky when the ips is not the same for every run
            try
                filtered_TC = spm_filter(SPM.xX.K(1),unfiltered_TC);
            catch
                % truncate in case too many rows (i.e., when scan was stopped a lot later than it should've)
                SPM_xX_K_1 = SPM.xX.K(1);
                SPM_xX_K_1.row = 1:num_TC_total;
                SPM_xX_K_1.X0 = SPM_xX_K_1.X0(1:num_TC_total,:);
                
                filtered_TC = spm_filter(SPM_xX_K_1,unfiltered_TC);
            end
            
            zero_meaned_TC=zeros(size(unfiltered_TC,1), size(unfiltered_TC,2));
            
            mean_filtered_TC= mean(filtered_TC,1);
            
            zero_meaned_TC=bsxfun(@minus,filtered_TC,mean_filtered_TC);
            
            zero_meaned_TC_total(1:num_TC_total,:)= zero_meaned_TC; % this way for ROI-based MVPA
            %     zero_meaned_TC_total(1:num_TC_total,:,sess_num)= zero_meaned_TC; % this way for searchlight (verify)
            
        % end;
        
        save (mat_file_name, 'zero_meaned_TC_total','-v7.3');
        
        clear zero_meaned_TC_total; clear XYZ;
    % catch
        % sprintf('No %s for subject %s',mask_image_name,subj_dirs{subj_num});
    % end
end  %%% End of loop through subjects
end %end function
