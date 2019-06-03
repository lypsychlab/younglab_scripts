% Kevin Jiang
% Last updated: 5/28/19

% helper function for fmriprep
% returns array of behavioural run numbers associated with this study/subj/taskname
% based on 'mat' row specified in infile
% assumptions: run numerics are the only numerics in row, no gaps between runs
% removes all NaN entries from list before returning
% used by: add_acompcor_regressors.m, younglab_model_som12_sirius_BIDS.m

% Parameters:
% - root_dir: pathname, (on siriius: '/home/younglw/lab')
% - study: name of the study folder 'FIRSTTHIRD'
% - subj: subject name
% - taskname: name by which to identify behavioral .mats
% - infile: full path or file name (if in root_dir/study) of infile; runs paraemter rendered irrelevant

function [out] = extract_behav_runs_from_infile(root_dir,study,subj,taskname,infile)
    out = []; % default at empty list in case study/subj/taskname not specified in infile
    try % if infile is full path
        T = readtable(infile);
    catch % if infile in root_dir/study folder
        T = readtable(fullfile(root_dir,study,infile));
    end
    for i = 1:height(T)
        if strcmp(T{i, 'SubjID'}{1}, subj) && strcmp(T{i, 'Task'}{1}, taskname) && strcmp(T{i, 'Type'}{1}, "mat")
            % return all numeric values in this row i.e., all behavioural run values 
            % (assumes these are only numerics file)
            % handles different number of runs in different tasks
            out = T{i, vartype('numeric')};
            % T(i,{'BidsRun1', 'BidsRun2', 'BidsRun3', 'BidsRun4', 'BidsRun5', 'BidsRun6', 'BidsRun7', 'BidsRun8', 'BidsRun9', 'BidsRun10'})

            % remove all Nan entries from list
            % assumes Nan entries can only be at end of list!
            % (check infile to make sure this is the case!)
            out = out(~isnan(out))
            
            return;
        end 
    end
end