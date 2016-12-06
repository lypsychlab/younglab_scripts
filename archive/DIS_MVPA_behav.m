
data=csvread('Verbs_design.csv');
save_dir='/home/younglw/PSYCH-PHYS/behavioural/';
cd(save_dir); mkdir('verbs_emily'); cd('verbs_emily'); save_dir=pwd;

 %make sure to strip off the first line column headings

subjIDs=data(:,1);
runs=data(:,2);
onsets=data(:,3);
old_design=data(:,4);
RTs=data(:,5);
keys=data(:,6);
items=data(:,7);
int_run=data(:,8);
designs=data(:,9);

%we now have data in MATLAB that looks exactly like the excel data

%condition names
cond_names=[cellstr('Knew_Acc'),cellstr('Knew_Int'),cellstr('Real_Acc'),cellstr('Real_Int'),cellstr('Saw__Acc'),cellstr('Saw__Int')];

%cond_numbers=[1 2 3 4 5 6];

%contrast vectors: 
%number of contrasts = 28
%THIS IS DONE - RETURN FOR EVERY RUN
contrast_names = [cellstr('knew____ vs real____');cellstr('real____ vs knew____');cellstr('knew____ vs saw_____');cellstr('saw_____ vs knew____');...
cellstr('real____ vs saw_____');cellstr('saw_____ vs real____');...
cellstr('knowreal vs saw_____');cellstr('saw_____ vs knowreal');cellstr('knew_int vs knew_acc');cellstr('knew_acc vs knew_int');cellstr('real_int vs real_acc');...
cellstr('real_acc vs real_int');cellstr('saw__int vs saw__acc');cellstr('saw__acc vs saw__int');cellstr('knew_int vs real_int');cellstr('real_int vs knew_int');...
cellstr('knew_int vs saw__int');cellstr('saw__int vs knew_int');cellstr('real_int vs saw__int');cellstr('saw__int vs real_int');cellstr('knew_acc vs real_acc');...
cellstr('real_acc vs knew_acc');cellstr('knew_acc vs saw__acc');cellstr('saw__acc vs knew_acc');cellstr('real_acc vs saw__acc');cellstr('saw__acc vs real_acc');...
cellstr('int_____ vs acc_____');cellstr('acc_____ vs int_____')];
contrast_values = [1 1 -1 -1 0 0;-1 -1 1 1 0 0; 1 1 0 0 -1 -1;-1 -1 0 0 1 1; 0 0 1 1 -1 -1; 0 0 -1 -1 1 1;...
1 1 1 1 -1 -1; -1 -1 -1 -1 1 1; -1 1 0 0 0 0; 1 -1 0 0 0 0; 0 0 -1 1 0 0;...
0 0 1 -1 0 0; 0 0 0 0 -1 1; 0 0 0 0 1 -1; 0 1 0 -1 0 0; 0 -1 0 1 0 0;...
0 1 0 0 0 -1; 0 -1 0 0 0 1; 0 0 0 1 0 -1; 0 0 0 -1 0 1; 1 0 -1 0 0 0;...
-1 0 1 0 0 0; 1 0 0 0 -1 0; -1 0 0 0 1 0; 0 0 1 0 -1 0; 0 0 -1 0 1 0;...
-1 1 -1 1 -1 1; 1 -1 1 -1 1 -1];
for i=1:length(contrast_names)
	con_info(1,i).name = contrast_names(i);
	con_info(1,i).value = contrast_values(i,:);
end

ips = 167;

%create a 3d cell array that indexes (subjID,run,variable)
%each cell contains a vector for the given ID, run, and variable (e.g. onsets)

data_matrix=cell(47,6,9);

for i=1:length(subjIDs)
	%onsets will all be in (subj,run,3)
	%z-coordinate corresponds to column of that data in Verbs_design for easy lookup
	%most of these don't get used...but they are here if you need them!
	%note that some of the matrix is empty so don't loop starting at 1
	data_matrix{subjIDs(i),runs(i),3}=[data_matrix{subjIDs(i),runs(i),3} onsets(i)];
	% data_matrix{subjIDs(i),runs(i),4}=[data_matrix{subjIDs(i),runs(i),4} old_design(i)];
	% data_matrix{subjIDs(i),runs(i),5}=[data_matrix{subjIDs(i),runs(i),5} RTs(i);
	% data_matrix{subjIDs(i),runs(i),6}=[data_matrix{subjIDs(i),runs(i),6} keys(i)];
	% data_matrix{subjIDs(i),runs(i),7}=[data_matrix{subjIDs(i),runs(i),7} items(i)];
	% data_matrix{subjIDs(i),runs(i),8}=[data_matrix{subjIDs(i),runs(i),8} int_run(i)];
	data_matrix{subjIDs(i),runs(i),9}=[data_matrix{subjIDs(i),runs(i),9} designs(i)];

end

for j=3:47 %loop subjects
	for k=1:6 %loop runs
		sub=num2str(j);
		rn=num2str(k);
		disp(['Subject ' sub ' Run ' rn]);
		design=data_matrix{j,k,9};
		if any(design==0)
			continue;
		end

		for m=1:length(cond_names)
			spm_inputs(m).name=cond_names(m);
			spm_inputs(m).ons=[];
		end

		for n=1:length(design) %for every value in the designs vector
			%grab the appropriate onset value - data_matrix{j,k,3}(n) 
			%and add it into the spm_inputs.onset array at the correct location - 1,data_matrix(j,k,9)(n)
			spm_inputs(design(n)).ons = [spm_inputs(design(n)).ons data_matrix{j,k,3}(n)];
		end

		for m=1:length(cond_names)
			spm_inputs(m).dur = repmat([11],length(spm_inputs(m).ons),1);
		end

		save(fullfile(save_dir,['DIS_behav_' sprintf('%02d',j) '_' rn '.mat']), 'design', 'spm_inputs', 'ips', 'con_info');
	end
end






    
      









