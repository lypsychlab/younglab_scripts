function [result, char_results] = adir(search_str,full_file)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% this is an adaptation of MATLAB's 'dir' function ('advanced dir')
	% that wraps the ls command and parses its output. 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% search_str is the search string, i.e., a the pattern to match. 
	% full_file is a boolean, either 1 or 0 (or omitted); if 1, the
	% function will return the full file + location.
	% 
	%		e.g., 
	%
	%				results = adir('*/*YOU*')
	%				results = adir('*YOU*',1)
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% results is a cell array of file/directory names. char_results is that
	% same set of names but expressed as a char array. 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	command = ['ls -dm ' search_str];
	[status,result] = system(command);
	% exclude any letters that are *not* in the proper range, i.e., return
	% characters, etc
    if status~=0
        result = -1;
        char_results = -1;
        return
    end
	rnge = [double(' ')-1 double('~')+1];
	result = result(double(result) > rnge(1) & double(result) < rnge(2));
	% split by comma-spaces
	result = regexp(result,', *','split');
	if exist('full_file','var') && full_file
		% add in the full working directory
		result = cellfun(@(x) {fullfile(pwd,x)},result);
	end
	char_results = char(result);
end