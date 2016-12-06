%untitled2_emily_server:
% copy of Alek's script untitled2.m from the DIS_MVPA folder
% modified to run on the server

addpath(genpath('/software/spm/spm8'));
addpath(genpath('/software/spm_ss'));
% spm fmri
addpath(genpath('/sofware/conn15')); % previously from /software/gablab/conn in saxelab
addpath(genpath('/younglab/scripts'));
% 
% mkdir('/mnt/englewood/data/PSYCH-PHYS/Alek_replication');
% cd('/mnt/englewood/data/PSYCH-PHYS/Alek_replication/')
%original set of subjects (N=21)
experiments=struct(...
    'name','PSYCH-PHYS',... % study name
    'pwd1','/mnt/englewood/data/PSYCH-PHYS/',...   % folder with participants
    'pwd2','results/DIS_results_normed_smoothed/',...   % inside each participant, path to SPM.mat
    'data',{{...
    'SAX_DIS_03','SAX_DIS_04','SAX_DIS_05','SAX_DIS_06','SAX_DIS_07',...
    'SAX_DIS_08','SAX_DIS_09','SAX_DIS_10','SAX_DIS_11','SAX_DIS_12',...
    'SAX_DIS_13','SAX_DIS_14','SAX_DIS_27','SAX_DIS_28','SAX_DIS_32',...
    'SAX_DIS_34','SAX_DIS_38','SAX_DIS_40','SAX_DIS_41','SAX_DIS_42',...
    'SAX_DIS_45','SAX_DIS_46'}});
%minus 06 and 43
% experiments=struct(...
%     'name','PSYCH-PHYS',... % study name
%     'pwd1','/mnt/englewood/data/PSYCH-PHYS/',...   % folder with participants
%     'pwd2','results/DIS_results_normed_smoothed/',...   % inside each participant, path to SPM.mat
%     'data',{{...
%     'SAX_DIS_03','SAX_DIS_04','SAX_DIS_05','SAX_DIS_07',...
%     'SAX_DIS_08','SAX_DIS_09','SAX_DIS_10','SAX_DIS_11','SAX_DIS_12',...
%     'SAX_DIS_13','SAX_DIS_14','SAX_DIS_27','SAX_DIS_28','SAX_DIS_32',...
%     'SAX_DIS_34','SAX_DIS_38','SAX_DIS_40','SAX_DIS_41','SAX_DIS_42',...
%     'SAX_DIS_45','SAX_DIS_46'}});
mkdir(fullfile(experiments.pwd1,'logs'));
diary(fullfile(experiments.pwd1,'logs',['untitled2_emily_server_sim_' date '.txt']))
partition_names     = {'Even ','Odd '};
%condition_names     = {'accidental harm','intentional harm'};
condition_names     = {'accidental harm','intentional harm'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roin                = 'RTPJ';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% locates appropriate subject-level files
disp('locating appropriate subject-level files');
spm_data=[];
datafilename={};
if ~isempty(experiments)
    for nsubject=1:numel(experiments.data),
        fprintf(['now on subject ' num2str(nsubject) '\n']);
        
%         current_spm    = fullfile(experiments.pwd1,experiments.data{nsubject},experiments.pwd2,'SPM.mat');
%         [spm_data,SPM] = spm_ss_importspm(spm_data,current_spm);
%         Cnames         = {SPM.xCon(:).name};
%         ic=[];ok=1;
        simfolder='3_3';
        cd(fullfile(experiments.pwd1,experiments.data{nsubject},'results/simulation',simfolder));
        fprintf(['Current dir: ' pwd '\n']);
        load([experiments.data{nsubject} '.mat']);
        datafilename{nsubject,1,1}=R(:,1:2:12); % dummy Even/Acc
        datafilename{nsubject,1,2}=R(:,2:2:12); % dummy Even/Int
        datafilename{nsubject,2,1}=R(:,13:2:24); % dummy Odd/Acc
        datafilename{nsubject,2,2}=R(:,14:2:24); % dummy Odd/Int
        clear R;
%         for n1=1:numel(partition_names),% Even, Odd
%             for n2=1:numel(condition_names),% Accidental, Intentional
%                 temp = strmatch([partition_names{n1},condition_names{n2}],Cnames,'exact');if numel(temp)<1,ok=0;break;else ic(n1,n2)=temp(1);end;
%                 
%                 % datafilename is 22(subject) x 2(even,odd) x 2(accidental,intentional)
% %                 datafilename{nsubject,n1,n2}=fullfile(fileparts(current_spm),['con_',num2str(ic(n1,n2),'%04d'),'.nii']);
%             end
%         end
%         if ~ok, error(['contrast name ',[partition_names{n1},condition_names{n2}],' not found at ',current_spm]); end
    end
end

% load data
for ncondition=1:numel(condition_names),% accidental, intentional
    if ~isempty(datafilename)
        for s = 1:length(experiments.data) %for all subjects
            thesubj = regexp(experiments.data{s},'/','split');
            thesubj = thesubj{end};
%             try
%                 roi_file = dir([experiments.pwd1 experiments.data{s} '/roi/*' roin '*.img']);
%                 roi  = fullfile(experiments.pwd1,experiments.data{s},'roi',roi_file(1).name);
              Data_part1(ncondition).(thesubj)=datafilename{s,1,ncondition};
              Data_part2(ncondition).(thesubj)=datafilename{s,2,ncondition}; 
%                 Data_part1(ncondition).(thesubj) = rex(char({datafilename{s,1,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',1,'disregard_zeros',0)'; % subjects x voxels data
%                 Data_part2(ncondition).(thesubj) = rex(char({datafilename{s,2,ncondition}}),roi,'level','voxels','select_clusters',0,'selected_clusters',1,'disregard_zeros',0)'; % subjects x voxels data
%             catch
%                 fprintf(['\n cannot find ' experiments.data{s} roi '\n']);
%             end
%                   Data_part1(ncondition).(s)
        end
    else
    end
end

nsubjects = length(fieldnames(Data_part1));
names     =        fieldnames(Data_part1);

% gets rid of nans and centers (across conditions)
for subj = 1:length(fieldnames(Data_part1))
    for n = 1:length(Data_part1)
        Data_part1(n).(names{subj}) = Data_part1(n).(names{subj})(~isnan(Data_part1(n).(names{subj})));
        Data_part2(n).(names{subj}) = Data_part2(n).(names{subj})(~isnan(Data_part2(n).(names{subj})));
        stddevs1(n).(names{subj})=std(Data_part1(n).(names{subj}));
        stddevs2(n).(names{subj})=std(Data_part2(n).(names{subj}));       
    end
end

% correlations
R = nan(2,2,nsubjects);
for nsubject=1:nsubjects,
    for ncondition1=1:numel(condition_names),% accidental, intentional
        for ncondition2=1:numel(condition_names),% accidental, intentional
            %try
                % Spatial correlations: condition x condition x subjects x partitionpairs
                R(ncondition1,ncondition2,nsubject) =...
                    corr(Data_part1(ncondition1).(names{nsubject}),...
                         Data_part2(ncondition2).(names{nsubject}));
            %catch
           % end
        end
    end
end

R_wb = [mean([squeeze(R(1,1,:)) squeeze(R(2,2,:))],2) mean([squeeze(R(2,1,:)) squeeze(R(1,2,:))],2)];

Z    = atanh(R);% transformed
Z_wb = [mean([squeeze(Z(1,1,:)) squeeze(Z(2,2,:))],2) mean([squeeze(Z(2,1,:)) squeeze(Z(1,2,:))],2)];

mean(Z_wb)
rmpath(genpath('/software/spm/spm8/external/fieldtrip/'));

[h,p] = ttest(Z_wb(:,1),Z_wb(:,2)) %finally.
notes = 'subj  bad';
mkdir(fullfile(experiments.pwd1,'results/simulation',simfolder));
cd(fullfile(experiments.pwd1,'results/simulation',simfolder));

save(['MVPA_data_simulated_RTPJ.mat'],'R','Z','R_wb','Z_wb','Data_part1','Data_part2','notes')
diary off;