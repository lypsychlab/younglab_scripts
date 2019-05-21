function subjIDs = makeIDs_fullpath(studydir, studystring, numlist)
% This is a quick script generate a list of formatted subjIDs 
% given a single string for the study and an array of numbers.
% The output will be a cell array with cells:
% {'SAX_studystr_num1','SAX_studystr_num2',SAX_studystr_numX...}
%
% E.G. makeIDs('CUES',[1:20])

i=1;
for num=numlist
    
    subjIDs{i} = fullfile(studydir, sprintf('YOU_%s_%02d', studystring, num));
	i=i+1;
end