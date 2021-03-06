function remodeler(varargin)

% remodeler
% 
% re-models the data using either artifact regressors, motion regressors, or
% both types of regressors. 
% 
% Input during the function call is not strictly necessary, it will obtain 
% all information it absolutely requires for proper function from the user. 
% 
% However, any parameters you wish can be passed to modeling script by 
% including them in the function call. Therefore, 
% 
% remodeler('maskthresh = 0.6','filter_frequency = 250')
% 
% Will cause the script to call saxelab_newmodel_spm8 and set the masking 
% threshold to 0.6, and the filtering frequency to 250 seconds per cycle. 
% 
% This is particularly useful when the behavioral files will cause the 
% modeling script to ask for a new frequency. While newmodel can handle 
% batch requests, remodeler calls it one-task-one-subject at a time, and 
% therefore if remodeler is batched it is recommended you tell it what 
% frequency you wish it to use ahead of time, or else it will request
% a new frequency each and every time. 
% 
% *********NOTES
% 
% - remodeler disables art_batch when it's re-modeling. 
% - remodeler expects that you wish to use the same mask image as in the 
%     original analysis. If this is not the case, call remodeler with 
%     'overwrite_mask' to prevent it from doing this. 
% - [] indicate the default value of an input. If you see this convention
%     and you wish to use the default value, you do not need to provide 
%     input (you can instead just hit enter)
% - the metadata produced by newmodel when it is called by this script is
%     misleading in the values it lists for art_batch. These are not 
%     necessarily the correct values -- they're just the default values. 
%     The actual parameters are those of the most recent modeling run before
%     this one. 
% 
% created by npd 11/12/2010
%
%
% What follows is the helpfile for saxelab_newmodel_spm8:
%
%
%
% saxelab_newmodel_spm8
% 
% Batch function for specifying and modeling a design matrix for one or
% more subjects in SPM8. At the minimum, it requires four arguments at the
% beginning: study, subject IDs, tasks, and bold directories. 
%
% E.G. saxelab_newmodel_spm8('BLI','SAX_BLI_01','fba',[4 8 14])
%       ==> would attempt to model  audio fb task (fba) for bold runs 005,
%           009, and 014 in a new directory called
%           '<experiment root dir>/BLI/SAX_BLI_01/results/fba_results'
%
% In addition, there are a number of optional parameters that affect the 
% behavior of the script. By default, the following behavior will take
% place:
%         - Use an explicit mask generated by FSL with a threshold of 0.5
%         - Run art_batch, saving the regressors and including a screenshot
%             of the results, but not including the regressors in the 
%             behavioural files. 
%         - Use a filtering frequency of 128 seconds per cycle. 
%         - Assume data are normalized.
%         
% *********************** Options *****************************************
% All parameters may be modified by including extra arguments to the script
% in the form of strings. There are two types, "option" parameters and 
% assignment parameters. Option parameters are single inputs that cause the
% script to change between discrete modes of operation. Assignment 
% parameters change the value of a variable. 
% 
% Option parameters:
%     => 'RT'             Causes the script to integrate reaction-time 
%                         regressors
%                         
%     => 'unnormed'       The script will expect unnormalized data.
%     
%     => 'implicit_mask'  The script will use SPM's implicit masking, with a 
%                         default masking threshold of 80% mean signal.
%                         
%     => 'no_art'         The script will not run artifact detection.
%     
%     => 'legacy'         The script will function exactly as its 
%                         predecessor, saxelab_model_bch_spm8.
%     
%     => 'overwrite_mask' The script's default behavior is now to overwrite 
%                         any mask that it finds. The 'overwrite_mask'
%                         option (confusingly) will disable this, causing
%                         it to *not* overwrite the mask. 
% Assignment parameters:
%     These variables all change the behavior of the script by directly
%     changing the value of a variable.
%     => 'maskthresh = number'
%         Changes the masking threshold. Remember, whereas SPM uses percent
%         as the means of expressing the masking threshold, FSL uses 
%         decimal values. Therefore, '80' in SPM as the masking threshold 
%         is the equivalent of '0.8' in FSL. 
%         Default (explicit mask): 0.5
%         Default (implicit mask): 80
%      
%     => 'filter_frequency = number'
%         Changes the frequency cutoff for the high pass filter. The script
%         will warn you if you attempt to use a bad filtering frequency,
%         but changing it ahead of time will circumvent that. Expressed as 
%         seconds-per-period. 'filter_frequency = 200' will filter anything
%         with a period greater than 200 seconds, or a frequency lower than
%         1/200 Hz. 
%         
%     => 'global_threshold = number' 
%         threshold for outlier detection based on global signal 
%         (default = 3)
%         
%     => 'motion_threshold = number' 
%         threshold for outlier detection based on motion 
%         (default = 2)
%         
%     => 'use_diff_motion = 1 or 0' 
%         1: uses scan-to-scan motion to determine outliers
%         0: uses absolute motion 
%         (default = 1)
%         
%     => 'use_diff_global = 1 or 0' 
%         1: uses scan-to-scan global signal change to determine outliers
%         0: uses absolute global signal values
%         (default = 0)
%         
%     => 'root_dir = STRING'      
%         Changes the root directory. Should probably not be used. If you
%         must change the root directory, you must pass it in with escaped
%         quotes. Like: 'root_dir = ''some string'''
%         
% Some usage examples:
% 
% saxelab_newmodel_spm('MNM',{'SAX_MNM_01','SAX_MNM_02'},'mnm',[6 8 10 12],'unnormed','implicit_mask','maskthresh = 60');
% 
%     This would perform the analysis, but on unnormed data, and using SPM's 
%     own masking system. Since the masking threshold defaults to 80% if you 
%     specify an implicit mask, the user has changed it to 60%. 
% 
% Additional Notes:
% 
%     - The script saves a screenshot of the art_batch results as 
%       artifact_analysis_SUBJECT_TASK.png
%     - The script will never overwrite old data, instead it will simply 
%       create a new results directory with the same name but a "2" or "3" 
%       (etc) appended to it.
%     - The script saves information about who performed the analysis, 
%       when it was performed, and the parameters used in a text file stored
%       in the results directory, named 'whatever the results directory is + 
%       metadata.txt'
%     - The script remodeler() will integrate artifact data, by changing 
%       the behavioural files and modeling again using this script.
%        
%  ======================= Multi-subject/task batching =======================
% The logic governing the interpretation of 'subjIDs' is the same as in
% the dicom and preprocessing scripts - If provided with a string the
% script will search through '<software root dir>/study' for a match, and if none is
% found it will attempt to use this string as a filter on this directory
% instead.  The script interprets a cell array as a list of subjects.
%
% Both 'tasks' and 'boldirs' may also be elaborated into cells that
% saxelab_model_bch will then attempt to step through, but the effect is the
% same as repeating the function call with each argument.  For both args,
% provide information about the task within subject information.  That is,
% provide a cell that contains a series of task cells within subject cells.
%       e.g. {{'task1','task2'},{'task1','task3'}}
%
% E.G. (simple)
% saxelab_newmodel_spm8('BLI','SAX_BLI_01','fbv',[3 10 13])
% E.G. (crazy)
% saxelab_newmodel_spm8('BLI',{'SAX_BLI_01','SAX_BLI_02','SAX_BLI_03'},...
% {{'fba','fbv','BLI'},{'fba','BLI},{'fbv','fba','BLI'}},{{[5 9 ...
% 14],[3 10 13],[7 8 11 12]},{[5 10 13],[7 8 11 12]},{[3 9 12],[4 8 13],...
% [6 7 10 11]}})
% This one actually would work, provided behavioural data, but in practice
% will typically only be run by your pstream script in which all these
% values are hard coded.

% Usage note:
% 1) This script depends on the presense of the 2 variables 'ips' and
% 'spm_inputs' in an individual mat file for every run that is to be
% included in the model.  These matfiles should be located in the 'study'
% directory and named with the following format: subjID.task.acq.mat
%       ips is a integer used to set the number of functional runs
%       spm_inputs is a scructure with fields name, ons, and dur
%
% 2) The script also searches for the optional variables "con_info" and
% "user_regressors".
%   Syntax:
%       con_info(index).name = 'some name';
%       con_info(index).vals = [array of values of length numruns];
%
%       user_regressors(index).name = 'regressor name';
%       user_regressors(index).ons = [array of numbers of length ips];
%       
%
% 3) IMPORTANT: these files are loaded by filtering the directory, NOT
% directly.  Therefore the script knows nothing of acq numbers, and to
% exclude a run from the model you must MOVE/REMOVE the appropriate matfile
% from the behavioural directory.  It is not enough to simply omit the bold
% directory in the function call (unless it was the last run), since the
% script sequentially pairs the list of matfiles to corresponding boldirs.
% 4) In cases where tasks or boldirs is the same across subjects you may
% omit repetitions - the script copies the first cell out to the
% appropriate number of subjects

fprintf('---------------------------------------------\n');
fprintf('----------------SAXELAB REMODELLER-----------\n');
fprintf('---------------------------------------------\n');
fprintf('\n')
fprintf('\n')
vararginin = varargin;
data.experimentDir = '/mindhive/saxelab/';

instructions(1);tempStudy       = input(sprintf('Enter study name:\t\t\t'                   ), 's');
instructions(2);tempSubjects    = input(sprintf('Enter subject IDs, separated by commas:\t' ), 's');
instructions(3);tempBehavName   = input(sprintf('Enter subject task:\t\t\t'                 ), 's');
instructions(4);tempRunNums     = input(sprintf('Enter the runs you want analyzed:\t'       ), 's');
instructions(5);tempBoldDirs    = input(sprintf('Enter the bold directories for data\t'     ), 's');
tempRegs        = questdlg('Regressors to include','Regressors','Artifact Only','Motion Only','Artifact and Motion','Artifact Only');
if strcmp(tempRegs,'Artifact Only')
    tempRegs = 1;
elseif strcmp(tempRegs,'Motion Only')
    tempRegs = 2;
elseif strcmp(tempRegs,'Artifact and Motion')
    tempRegs = 3;
end
tempREX         = questdlg('Include REX regressors?','REX Regressors','Yes','No','No');
if strcmp(tempREX,'Yes')
    tempREX = 1;
elseif strcmp(tempREX,'No')
    tempREX = 0;
end
tempNormed      = questdlg('Is the data normalized?','Normalization','Yes','No','Yes');
if strcmp(tempNormed,'Yes')
    tempNormed = 'y';
elseif strcmp(tempNormed,'No')
    tempNormed = 'n';
end
tempDeleteBehav = questdlg('Attempt to delete old art_reg behav files? [Necessary to perform analysis]','Remove old files','Yes','No','Yes');
if strcmp(tempDeleteBehav,'Yes')
    tempDeleteBehav = 'y';
elseif strcmp(tempDeleteBehav,'No')
    tempDeleteBehav = 'n';
end
%tempRegs        = input(sprintf('Regressors to include (1 - artifact, 2 - motion, 3 - both):\t'     ), 's');
%tempREX         = input(sprintf('Include REX regressors?: 1 - yes, 0 - no\t'), 's');
%tempNormed       = input(sprintf('Normed? [y]/n:\t'),'s');
%tempDeleteBehav       = input(sprintf('Attempt to delete old art_reg behav files? (necessary to perform analysis) [y]/n:\t'),'s');
eval(sprintf('tempRunNumsEval = %s;',tempRunNums));
eval(sprintf('tempBoldDirsEval = %s;',tempBoldDirs));
%eval(sprintf('tempRegs = %s;',tempRegs));
%eval(sprintf('tempREX = %s;',tempREX));
tempSubjectsSplit = regexp(tempSubjects,',','split');                               %split by commas

for i=1:length(tempSubjectsSplit)
    data(i).study = tempStudy;
    data(i).subject = tempSubjectsSplit{i};
    data(i).behavName = tempBehavName;
    switch tempRegs
        case 1
            data(i).artbehavName = [tempBehavName '_with_art_reg'];
        case 2
            data(i).artbehavName = [tempBehavName '_with_mot_reg'];
        case 3
            data(i).artbehavName = [tempBehavName '_with_art_and_mot_reg'];
    end
    if tempREX
        data(i).artbehavName = [data(i).artbehavName '_REX'];
    end
    data(i).boldDirs = tempBoldDirsEval{i};
    for j=1:length(tempBoldDirsEval{i})
        data(i).bold(j).name = sprintf('%03.0f',tempBoldDirsEval{i}(j));
        data(i).run(j).name = sprintf('%.0f',tempRunNumsEval{i}(j));
    end
end

fprintf('Looking for folders...\n');
% Begin checking for existence of folders
for i=1:length(data)
    if exist([data.experimentDir data(i).study],'dir')
        if exist([data.experimentDir data(i).study '/' data(i).subject],'dir')
            data(i).subjectDir = [data.experimentDir data(i).study '/' data(i).subject];
            for j=1:length(data(i).bold)
                if exist([data.experimentDir data(i).study '/' data(i).subject '/bold/' data(i).bold(j).name],'dir')
                    data(i).bold(j).dir = [data.experimentDir data(i).study '/' data(i).subject '/bold/' data(i).bold(j).name];
                else
                    fprintf('Couldn''t find bold directory %s for subject %s for study %s\n',data(i).bold(j).name,data(i).subject,data(i).study);
                    return;
                end
                if exist([data.experimentDir data(i).study '/behavioural/' data(i).subject '.' data(i).behavName '.' data(i).run(j).name '.mat'],'file')
                    data(i).run(j).dir = [data.experimentDir data(i).study '/behavioural/' data(i).subject '.' data(i).behavName '.' data(i).run(j).name '.mat'];
                    data(i).run(j).artdir = [data.experimentDir data(i).study '/behavioural/' data(i).subject '.' data(i).artbehavName '.' data(i).run(j).name '.mat'];
                else
                    fprintf('Couldn''t find behavioural file %s for run %s subject %s for study %s\n',data(i).behavName,data(i).run(j).name,data(i).subject,data(i).study);
                    return;
                end
            end
        else
            fprintf('Couldn''t find subject %s for study %s\n',data(i).subject,data(i).study);
            return;
        end
    else
        fprintf('Couldn''t find %s\n',data(i).study);
        return;
    end
end
fprintf('...all necessary files located!\n');
useSkullStripping        = questdlg('Use implicit masking or generate skull-stripped version?','Masking','Implicit','Skull Stripped','Skull Stripped');
if strcmpi(useSkullStripping,'Implicit')
    config.model.skullstripping = 0;
    useDefaultMask          = questdlg('Use default masking threshold for subjects? (default is 80 percent)','Threshold','Yes','No','Yes');
    %useDefaultMask          = input(sprintf('Use default masking threshold for subjects? [y]/n (default is 80 percent):\t\t'         ), 's');
    if strcmpi(useDefaultMask, 'No')
        cust_maskthresh     = input(sprintf('Enter desired masking threshold percent for subject:\t\t'          ), 's');
        eval(sprintf('config.model.maskthresh = %s;',cust_maskthresh));
    else
        config.model.maskthresh = 80;
    end
else
    config.model.skullstripping = 1;
    useDefaultMask          = questdlg('Use default skull stripping threshold?','Threshold','Yes','No','Yes');
    %useDefaultMask          = input(sprintf('Use default masking threshold for skull stripping? [y]/n (default is 0.4):\t\t'),'s');
    if strcmpi(useDefaultMask, 'No')
        cust_maskthresh     = input(sprintf('Enter desired masking threshold percent for subject:\t\t'          ), 's');
        eval(sprintf('config.model.maskthresh = %s;',cust_maskthresh));
    else
        config.model.maskthresh = 0.4;
    end
end

printTitle('Modifying behavioral files...');
for subjstep31=1:length(data)
    for behavstep31=1:length(data(subjstep31).run)
        if exist(data(subjstep31).run(behavstep31).artdir,'file')
            disp(fprintf('The file %s already exists!',data(subjstep31).run(behavstep31).artdir));
            if strcmpi(tempDeleteBehav,'n')
                disp('Found behavioral files, but since you selected not to delete them, the script is now terminating. Delete the files then try again.');
                return;
            else
                disp('Attempting to delete them...');
                try
                    delete(data(subjstep31).run(behavstep31).artdir);
                catch
                    input(sprintf('Unable to remove behavioural file %s, delete it yourself then hit any key followed by enter to continue',data(subjstep3).run(behavstep3).artdir), 's');
                end
            end
        end
    end
end
                
for subjstep3=1:length(data)
    for behavstep3=1:length(data(subjstep3).run)
        % first copy the behavioral files. 
        copyfile(data(subjstep3).run(behavstep3).dir,data(subjstep3).run(behavstep3).artdir);
        % now add regressors to the files. 
        load(data(subjstep3).run(behavstep3).artdir,'user_regressors');
        load(data(subjstep3).run(behavstep3).artdir,'con_info');
        load(data(subjstep3).run(behavstep3).artdir,'spm_inputs');
        load(data(subjstep3).run(behavstep3).artdir,'ips');
        if tempRegs == 1
            if strcmp(tempNormed,'n')|strcmp(tempNormed,'N')
                regFileTemp = dir([data(subjstep3).bold(behavstep3).dir '/*outliers_sr*']);
            else
                regFileTemp = dir([data(subjstep3).bold(behavstep3).dir '/*outliers_swr*']);
            end
            data(subjstep3).run(behavstep3).regFile = [data(subjstep3).bold(behavstep3).dir '/' regFileTemp.name];
            load(data(subjstep3).run(behavstep3).regFile);
            [foo sizeR] = size(R);
            [foo sizeC] = size(con_info);
            if sizeR > 0
                if ~exist('user_regressors')
                    for regress=1:sizeR
                        user_regressors(regress).name = sprintf('artifact_regressor_%03.0f',regress);
                        user_regressors(regress).ons = R(:,regress);
                    end
                    for cons=1:sizeC
                        con_info(1,cons).vals = [con_info(1,cons).vals zeros(1,sizeR)];
                    end
                else
                    for regress=1:sizeR
                        user_regressors(end+1).name=sprintf('artifact_regressor_%03.0f',regress);
                        user_regressors(end).ons = R(:,regress);
                    end
                    for cons=1:sizeC
                        con_info(1,cons).vals = [con_info(1,cons).vals zeros(1,((length(user_regressors) + length(spm_inputs)) - length(con_info(1,cons).vals)))];
                    end
                end
            end
        elseif tempRegs == 2
            regFileTemp = dir([data(subjstep3).bold(behavstep3).dir '/*outliers_and_movement*']);
            data(subjstep3).run(behavstep3).regFile = [data(subjstep3).bold(behavstep3).dir '/' regFileTemp.name];
            load(data(subjstep3).run(behavstep3).regFile);
            [foo sizeR] = size(R);
            [foo sizeC] = size(con_info);
            if ~exist('user_regressors')
                for regress=1:6
                    user_regressors(regress).name = sprintf('motion_regressor_%03.0f',regress);
                    user_regressors(regress).ons = R(:,regress);
                end
                for cons=1:sizeC
                    con_info(1,cons).vals = [con_info(1,cons).vals zeros(1,6)];
                end
            else
                for regress=1:6
                    user_regressors(end+1).name = sprintf('motion_regressor_%03.0f',regress);
                    user_regressors(end).ons = R(:,regress);
                end
                for cons=1:sizeC
                    con_info(1,cons).vals = [con_info(1,cons).vals zeros(1,((length(user_regressors) + length(spm_inputs)) - length(con_info(1,cons).vals)))];
                end
            end
        elseif tempRegs == 3
            regFileTemp = dir([data(subjstep3).bold(behavstep3).dir '/*outliers_and_movement*']);
            data(subjstep3).run(behavstep3).regFile = [data(subjstep3).bold(behavstep3).dir '/' regFileTemp.name];
            load(data(subjstep3).run(behavstep3).regFile);
            [foo sizeR] = size(R);
            [foo sizeC] = size(con_info);
            if ~exist('user_regressors')
                for regress=1:6
                    user_regressors(regress).name = sprintf('motion_regressor_%03.0f',regress);
                    user_regressors(regress).ons = R(:,regress);
                end
                for regress=7:sizeR
                    user_regressors(regress).name = sprintf('artifact_regressor_%03.0f',regress);
                    user_regressors(regress).ons = R(:,regress);
                end
                for cons=1:sizeC
                    con_info(1,cons).vals = [con_info(1,cons).vals zeros(1,sizeR)];
                end
            else
                for regress=1:6
                    user_regressors(end+1).name = sprintf('motion_regressor_%03.0f',regress);
                    user_regressors(end).ons = R(:,regress);
                end
                for regress=1:sizeR
                    user_regressors(end+1).name=sprintf('artifact_regressor_%03.0f',regress);
                    user_regressors(end).ons = R(:,regress);
                end
                for cons=1:sizeC
                    con_info(1,cons).vals = [con_info(1,cons).vals zeros(1,((length(user_regressors) + length(spm_inputs)) - length(con_info(1,cons).vals)))];
                end
            end
        end
        if tempREX
            load([data.experimentDir data(subjstep3).study '/' data(subjstep3).subject '/REX.mat'])
            if ~exist('user_regressors')
                user_regressors(1).name = 'REX';
                user_regressors(1).ons = params.ROIdata(((behavstep3-1)*ips)+1:(behavstep3)*ips);
            else
                user_regressors(end+1).name = 'REX';
                user_regressors(end).ons = params.ROIdata(((behavstep3-1)*ips)+1:(behavstep3)*ips);
            end
            con_info(1,cons).vals = [con_info(1,cons).vals 0];
            clear params;
        end
        if exist('user_regressors')
            save(data(subjstep3).run(behavstep3).artdir,'user_regressors','-append')
        end
        save(data(subjstep3).run(behavstep3).artdir,'con_info','-append')
        clear R;
        clear user_regressors;
        clear con_info;
        clear spm_inputs;
        clear ips;
    end
end

for subjstep4=1:length(data)
    if strcmp(tempNormed,'n')|strcmp(tempNormed,'N')
        option1 = 'unnormed';
    else
        option1 = 'disp(''no option1'')';
    end
    if ~config.model.skullstripping
        option2 = 'implicit_mask';
    else
        option2 = 'disp(''no option2'')';
    end
    option3 = 'no_art';
    option4 = sprintf('maskthresh = %1.2f;',config.model.maskthresh);
    if ~isempty(vararginin)
        function_call = 'saxelab_newmodel_spm8(data(subjstep4).study, data(subjstep4).subject, data(subjstep4).artbehavName, data(subjstep4).boldDirs,option1,option2,option3,option4';
        for i=1:length(vararginin)
            function_call = [ function_call ',''' vararginin{i} ''''];
        end
        function_call = [function_call ');'];
    else
        function_call = 'saxelab_newmodel_spm8(data(subjstep4).study, data(subjstep4).subject, data(subjstep4).artbehavName, data(subjstep4).boldDirs,option1,option2,option3,option4);';
    end
    eval(function_call);
end
end

function instructions(i)
    instruct = { ... 
        'Enter study name without quotes e.g., SAD', ...
        'Enter subject IDs without quotes, separated by commas with no spaces e.g., SAX_SAD_01,SAX_SAD_02,SAX_SAD_03', ...
        'Enter task without quotes e.g., MNM', ...
        'Enter run numbers as a cell array of number arrays e.g., {[1 2 3],[1 2 4],[1 2 3 4]}', ...
        'Enter the bold directories in a similar fashion as run numbers e.g., {[10 12 14],[10 12 16],[10 12 14 16]}' ...
        'What steps would you like performed?', ...
        'The steps work like this:', ...
        '1 - First model, either full or truncated.', ...
        '2 - Run art batch.', ...
        '3 - Integrate regressors into behavioral files.', ...
        '4 - re-run modeling.', ...
        'If you want steps 2 through 4 to be performed, enter [2 4], or if you only want 1 and 2 to be performed, [1 2].'};
    fprintf('\n%s\n',instruct{i});
end

function printTitle(string)
    fprintf('---------------------------------------------\n');
    fprintf('%s\n',string)
    fprintf('---------------------------------------------\n');
    fprintf('\n\n');
end