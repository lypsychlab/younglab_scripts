function subjIDs = makeIDs_fullpath(studystring, numlist)
% This is a quick script generate a list of formatted subjIDs 
% given a single string for the study and an array of numbers.
% The output will be a cell array with cells:
% {'SAX_studystr_num1','SAX_studystr_num2',SAX_studystr_numX...}
%
% E.G. makeIDs('CUES',[1:20])

i=1;
for num=numlist
    if num<10
	    subjIDs{i} = ['/home/younglw/lab/' studystring '/YOU_' studystring '_0' num2str(num)];
    else
        subjIDs{i} = ['/home/younglw/lab/' studystring '/YOU_' studystring '_' num2str(num)];
    end
	i=i+1;
end