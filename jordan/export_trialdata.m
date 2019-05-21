function export_trialdata
%% 
% This script runs through all specified behavioral files, and grabs
% the information that you specify. It will also grab the run and onset of
% each trial.

% This is useful for collecting trial-wise information quickly. 

% The order of the ouput columns will be: filename, ID, run, onset, then
% whatever variables you have asked for.
clear all

%% Setup
hmdr = '/home3/younglw/lab/TRAG/';
wkdr = 'behavioural/';
% hmdr = '/Users/Jordan/MEGA/Desktop/TRAG_ToM/';
% wkdr = 'behavioural/';
behav = 'FPMLocal.'; %behavioural file identifier. NOTE that everything to the right will be wildcarded.

all_IDs = cell(20,1); %correct to have number of rows equal to subjects.

outvars = {'design_run', 'items_run', 'RT', 'key'}; %output variables from behavioral file desired (not counting onset, which is included automatically).
    % Make sure to specify these at the level of each run, as this script
    % will iterate through multiple subject files.

n = 1; %used to deal with subject IDs not starting at 1.

for i = 3:24 % label subjects properly and create a list to run through.
   if (i == 17 || i ==18), continue %subjects to skip
   elseif i <= 9
       all_IDs{n} = ['YOU_TRAG_0', num2str(i)];
   elseif i >= 10
       all_IDs{n} = ['YOU_TRAG_', num2str(i)];
   else
   end
n = n+1 ;  
end % i
%% Main body. Should be no need to alter.
cd([hmdr wkdr])
for i = 1:numel(all_IDs)
    subj_files = dir([all_IDs{i} '*' behav '*']);
    
    for j=1:length(subj_files)
        current_file = subj_files(j);
        load(current_file.name);
        
        x = 0;
        for k = 1:numel(spm_inputs)
            x = x + numel(spm_inputs(k).ons); %determine number of onsets, without assuming they are the same for every condition.
        end % k
        notes = zeros(x, 2+numel(outvars));
        notes(:,1) = j;
                
        for k = 1:numel(spm_inputs) %collect onsets
            if k == 1
                temp = [spm_inputs(k).ons];
            else
                temp = [temp, spm_inputs(k).ons]; 
            end
        end % k
        notes(:,2) = sort(temp'); %sort the onsets, since all other variables are in order of onsets.
        
        for k = 1:numel(outvars) %collect specified variables, place them next to the onsets.
            if size(eval(outvars{k}), 2) > 1
                notes(:,k+2) = eval(outvars{k})';
            else
                notes(:,k+2) = eval(outvars{k});
            end
        end
        
        Filename = cell(x, 1);
        Filename(:) = {current_file.name};
        ID = cell(x, 1); %populate IDs names for the subject.
        ID(:) = {all_IDs{i}};
        
        body_run = num2cell(notes); %convert data into a cell
        data_run = [Filename, ID, body_run]; %concatenate IDs and data.
        
        if j ==1 %start creating output for first subject, or add to output for later subjects.
            data_sub = data_run;
        else
            data_sub = [data_sub; data_run];
        end
%         clear 'RT'; 'con_info'; 'design'; 'experimentDuration'; 'ips'; 'items'; 'key'; 'responses'; 'run'; 'spm_inputs'; 'subjID';       
    end % j
    if i ==1
       data = data_sub;
    else
        data = [data; data_sub];
    end
end % i
%% Titles and output
titles = ['Filename', 'ID', 'run', 'onset', outvars];
data = [titles; data];
save([behav 'behavioral_data.mat'], 'data');
% cell2csv([behav '_behavioral_data.csv'],data,',','2000');
clear all