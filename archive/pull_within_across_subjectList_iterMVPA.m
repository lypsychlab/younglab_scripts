function pull_withinacross(filename)
load ([filename, '.mat']) %load the results mat file
%iterate through filling one array with all of the between scores (as seen
%in results.participants(1,1).ROI.contrasts(1,1) 'between', for each
%subject, then draw from the results.ROI.within which has each within
%score for each subject.

% fileID=fopen([filename, '.csv'],'wt');
labels = ['ACCH_w','ACCP_w','INTH_w','INTP_w','ACCH_w','ACCP_w','INTH_w','INTP_w']; %use separate cells!
within = [results.ROI.within]
% between(1,:) = sprintf('A_ACCH_INTH_b','B_ACCH_INTH_b','A_ACCP_INTP_b''B_ACCP_INTP_b');
for i=1:17 
    between(i,:) = [results.participants(1,i).ROI.contrasts(1,1).between, ...
    results.participants(1,i).ROI.contrasts(1,2).between];
end
% fprintf(fileID, '%s',[',','Z-within (center) = ', num2str(Z_average(n1,n1),'%0.3f')]);
full_output= [within, between];
% cell2csv('Within_between_subjects.csv',full_output,',','2010'); %print to csv;
csvwrite([filename, '.csv'],full_output)
end
