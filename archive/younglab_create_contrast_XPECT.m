function younglab_create_contrast_XPECT(name, conditions,values, varargin)

% younglab_create_contrasts(contrast name, {conditions}, [values])
% conditions is a cell array of conditions
%	- these can be partial matches (i.e., 'music' for Sn(1) e_music*bf(1))
% values is a vector of the value of the corresponding conditions. 
%   - you can use wildcards, i.e., 'mus*c' for 'music'
%   - WARNING: bracket characters ('[' and ']') are NOT matched, and are
%   instead used to group other characters. Parenthesis ARE matched. 
%   - you can use brackets to create alternatives. 
%     if you want FB - FP, you would input [1 -1] for your values, and your
%     conditions would be something like {'false belief','false photograph'}
% this script will append the contrasts to the selected SPM files. 
% 
% Example:
%
% younglab_create_contrast('Even music runs vs. Odd language runs',{'[2468]*mus*','[1357]*lang*'},[1 -1])
% will match 
% Sn(2) music*bf(1)
% Sn(4) music*bf(1)
% Sn(6) music*bf(1)
% Sn(8) music*bf(1)
% and give it a value of '1' in the contrast as well as 
% Sn(1) language*bf(1)
% Sn(3) language*bf(1)
% Sn(5) language*bf(1)
% Sn(7) language*bf(1)
% and give it a value of '-1'.


% matching is CASE INSENSITIVE.

%destsubjT = spm_select(Inf,'mat','Choose subject SPM.mat destination files for contrast copying.','',pwd,'SPM.*',1);
destsubj = resultsDirFinderator();
doassoc = 0;

if ~iscell(conditions)
	if ischar(conditions)
		conditions = {conditions};
	elseif isfloat(conditions)
		doassoc = 1;
		thecondnumbs = conditions;
		conditions = {};
	end
end
goback = 0;
for i=1:length(destsubj)
	going = 1;
	fileZt = destsubj{i};
    fileZ = '';
    for let = 1:length(fileZt)
        if ~isspace(fileZt(let))
            fileZ = [fileZ fileZt(let)];
        end
	end
    disp(sprintf('Working on %s',fileZ));
    paths = fileparts(fileZ);
    while isspace(paths(end))
        paths = paths(1:end-1);
    end
    cd(paths);
    load(fileZ);
	try 
		SPM.xCon(1).c;
	catch
		going = 0;
	end
	if ~going
		fprintf('xCon field of SPM structure has not been defined, skipping\n',fileZ);
	else
	if doassoc==1 & i==1
		for cnum = 1:length(thecondnumbs)
			conditions{end+1} = SPM.xX.name{thecondnumbs(cnum)};
		end
	end
	% now build the contrast
	ctrst(1).name = name;
	ctrst(1).vals = zeros(size(SPM.xCon(1).c,1),1);
	unmatched = 0;
	for j=1:length(conditions)
		matches = 0;
		for k = 1:length(SPM.xX.name)
            txt = upper(SPM.xX.name{k});
            ptrn = strrep(upper(conditions{j}),'*','.*');
            ptrn = strrep(ptrn,'(','\(');
            ptrn = strrep(ptrn,')','\)');
            matches = regexp(txt,ptrn,'once');
			if ~isempty(matches)
				ctrst(1).vals(k) = values(j);
				matches = 1;
			end
		end
		if matches == 0
			unmatched = 1;
			unmatchedN = conditions{j};
			warning('Unable to find a match for condition %s',unmatchedN);
		end
    end
	if ~unmatched | (exist('varargin','var') && strcmpi(varargin{1},'nostop'))
        if strfind(SPM.SPMid,'SPM2')&i==1
            oldpath = path;
            goback = 1;
            fprintf('\n\n');
            disp('It looks like you''re using SPM2...');
            curdir = pwd;
            saxestart SPM2;
            cd(curdir);
        end
		SPM.xCon(end+1) = spm_FcUtil('Set',ctrst(1).name,'T','c',ctrst(1).vals,SPM.xX.xKXs);
        spm_contrasts(SPM)
		%regenCons();	
    else
        fprintf('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n');
		fprintf('Unable to find matches for some of your conditions! Skipping subject %s\n',fileZ);
        fprintf('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n');
        pause(2);
	end
	end
end
if goback
path(oldpath);
end
end
		
function sSubjs = resultsDirFinderator()
    expRoot		= '/younglab/studies/';
    studyName	= 'XPECT' % input(sprintf('Study name:\t\t'),'s');
    taskName    = 'YOU_XPECT_*'; % input(sprintf('Subject name (i.e., ''YOU_SHAPES_*''):\t'),'s');
%     taskName    = input(sprintf('Subject name (i.e., ''YOU_SHAPES_*''):\t'),'s');
    resultName	= 'XPECT.outcome_results_normed' % input(sprintf('Results folder name:\t'),'s');

        
    studyDir	= [expRoot studyName '/'];

    curDir = pwd;
    cd(studyDir)
    [a subjs] = system(sprintf('ls *%s*/results/*%s* -dm',taskName,resultName));
    subjs = regexp(subjs,', *','split');
    %[s,v] = listdlg('PromptString',sprintf('Please select your result directories (ctrl+click selects multiple)'),'ListString',subjs,'ListSize',[500 600]);
    for i=1:length(subjs)
        sSubjs{i} = [studyDir subjs{i} '/SPM.mat'];
    end
end
