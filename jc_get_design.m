function [Cond, VY, RT] = jc_get_design(spmfile)
% ---------------------
% The SPM2 version of Kalina Christoff's classic function,
% kc_get_design.  Data structures heavily borrowed from that
% code, but this implementation is new.
%
% This function can be used to extract a vector of
% condition-specific designs from an SPM2 SPM.mat file.
% This is primarily useful for multi-session designs, where
% the same "condition" may be repeated arbitrarily across
% some sessions.  It's often useful to have a measure of
% what that condition's parameters (onsets, etc.) are, in a
% session-non-specific manner, which is not by default saved
% in the SPM.mat file.  This functions looks through the
% SPM.mat file and attempts to accumulate repeated
% conditions, returning a vector of designs, one for each
% _condition_ - across all sessions.
%
% USAGE
% [Cond, VY] = jc_get_design(spmfile)
%
% Note that we don't have all the different options
% kc_get_design did, to build designs and so forth, nor do
% we bother returning much information that's easily
% readable from the SPM.mat file.
%
% spmfile = full-path filename of the SPM.mat file to
% extract the design from.
% VY = vector of memory-mapped image files.
% Cond = design structure with the following fields:
%       .name = name of the condition, stripped of all
%       reference to session
%       .iC = vector of indices of this condition within the
%       "full" U vector (created by concatenating all U
%       vectors for all sessions).
%       .iS = vector of indices of this condition within
%       each session's individual U vector.
%       .onidx = column vector of onsets of this condition in
%       scans/TRs, with respect to WHOLE experiment.  
%           %%% BIG NOTE: onidx starts at one!  Not zero!
%           So it's unlike the saved ons vector - the 1st
%           functional scan is equal to onset 1 in this
%           program's vector.  This makes onidx suitable
%           immediately as an index into the VY vector, and
%           makes this program parallel with kc_get_design.
%       .num_scans = a guess at the duration of this
%       condition, taken from the dur vector.
%
% Note that this Cond structure is slightly different - iC
% and iS index the condition only within the U vector, not
% the whole design matrix (which might include
% user-specified regressors, parametric mods, Volterra
% columns, etc.).  So iC and iS can't be used directly as
% indices into the design matrix.  Also note that .num_scans
% was always 32 / RT in Kalina's - here we actually get the
% duration from the SPM file.  Thanks, SPM2!

if ischar(spmfile)
    load(spmfile);
elseif isstruct(spmfile)
    SPM = spmfile;
else
    error('Input must be either filename or SPM structure!');
end

VY = SPM.xY.VY;
RT = SPM.xY.RT;
    
   
% We assume, as Kalina does, that a single name goes with
% one and only one condition across sessions
    
Cond = struct('name', [], 'iC', [], 'iS', [], 'onidx', [], 'num_scans', []);

condnames = {};
% accumulate all names first, then pick out
% unique ones
for s = 1:length(SPM.Sess)
    condnames = vertcat(condnames, SPM.Sess(s).U.name);
end
full_condnames = condnames; 
[condnames, unique_cond_idx, full_cond_idx] = unique(condnames);
    
for c = 1:length(condnames)
    Cond(c).name = condnames(c);
    Cond(c).iC = find(strcmpi(Cond(c).name, full_condnames)); % index in full U vector
    
    cond_base_onsets = [];
    for s = 1:length(SPM.Sess)
        iS = find(strcmpi(Cond(c).name, vertcat(SPM.Sess(s).U.name))); % index in session
        if ~isempty(iS)
            Cond(c).iS(s) = iS;
        else
            Cond(c).iS(s) = 0;
        end

        %assume a given condition is only once in a session
        if s > 1
            sess_offset = max(SPM.Sess(s-1).row) + 1;  %row starts counting at one, but ons counts from zero - we add one for the index.
        else
            sess_offset = 1;  % onsets start at zero, so we add one for the index of onidx.
        end
        if (Cond(c).iS(s)==0)
            % condition isn't in this session
            curr_onsets = [];
        else
            curr_onsets = SPM.Sess(s).U(Cond(c).iS(s)).ons;
            if (strcmp(SPM.xBF.UNITS, 'secs')) | (strcmp(SPM.xBF.UNITS, 'seconds'))
                % convert to scans
                curr_onsets = floor(curr_onsets / RT);  %floor subtracts the T0
            end
            curr_onsets = curr_onsets + sess_offset; 
        end 
        cond_base_onsets = vertcat(cond_base_onsets, curr_onsets(:));
        if Cond(c).iS(s)~=0
            Cond(c).num_scans = vertcat(Cond(c).num_scans, SPM.Sess(s).U(Cond(c).iS(s)).dur(:));
        end
    end
    Cond(c).onidx = cond_base_onsets;
    % num_scans is a vector of all the durations of all the
    % trials in this condition - take the max for now, until
    % we have some good reason to do otherwise.
    Cond(c).num_scans  = max(Cond(c).num_scans);
    Cond(c).iS = Cond(c).iS(:);
end





