function voxel_to_svm_general(betavals, labeldata, namestring, numfilters, filterstruct, labelindex, labelnames)

% betavals must be the FULL PATH to your input file (e.g. '/home/younglw/lab/scripts/timesplit_james_mvpa.mat') containing 
% the datastruct of beta values
% labeldata - csv file containing at least one label column with either 0 or 1 corresponding to each row of beta vals 
		  	% to be included in the mvpa classifier
          % FILE SHOULD ALSO CONTAIN FULL PATH
% namestring - User provided naming string to be appended to each subject mvpa string and separately appended to allsubjects.mat file
% numfilters - number of filter variables included (if 0 (i.e. running classificiation on all betavalues in betavals) type 0).
% Max number of filters accepted is 2, but code can be easily modified to accept as many as necessary. 
%filterstruct - User must provide a structure array of relevant filters in which every entry has a 'filter_index' field where values 
% contained in the field are the column indices (in csv file) of filter variables to be included. filterstruct() should also include a 
% 'filter_vals' field where values contained correspond to the values of the relevant filter variable to be included in analysis. 'filter_vals'
% MUST be in the same order (by variable) as column indices.
% labelindex - The index in the csv file that corresponds to the column containing label values 
		% Labels under this heading should be binary (represented as either 1 or 0). If they are not, re-code them so that they are. 
% labelnames - cell array where first element is label name (string) associated with 0 label, and second element
%label name associated with 1 label

f =load(betavals);

condition_data = csvread(labeldata,1,0); % start at row offset 1 to avoid column headers

label_col = condition_data(:, labelindex); %grabs column values for label of interest at column labelindex


all_corr = [];
all_soft = [];


if numfilters==2  % If there are two filter variables included
	filter1 = condition_data(:, filterstruct(1).filter_index); %grabs column values for filter 1
	filter2 = condition_data(:, filterstruct(2).filter_index); %grabs column values for filter 2 
	%Note: add necessary number of the above lines as needed depending on how many filter variables included
	for s = 1:length(f.subnums) % iterate through each subject
		label_array = {}; 
		data_matrix =[];
		subj = sprintf([f.subjtag '_%02d'],f.subnums(s)); %create subject name
		disp(['Working on subject ' subj]);
		eval(['dataset = f.data_struct.' subj ';']); %construct 'dataset' variable
		offset = 140*(s-1);
		for i = 1:140
			if filter1(i+offset) == filterstruct(1).filter_vals & filter2(i+offset) == filterstruct(2).filter_vals
			% add more AND conditionals to above line if more filters needed
				if label_col(i+offset) == 0 % if label associated with value 0
					label_array{end + 1} = labelnames{1}; % 
					data_matrix = [data_matrix; dataset(i, :)]; % nested inside if statement so that beta values only added to data_matrix 
				elseif label_col(i+offset) == 1  % if label associated with value 1
					label_array{end +1} = labelnames{2};
					data_matrix = [data_matrix; dataset(i, :)];
				end
			end
		end
		% keyboard

		[corracc,corrsoft]=younglab_svm_leavetwo(data_matrix, label_array, labelnames, ['svm_' namestring '_' subj '.mat']);
		all_corr=[all_corr; corracc];
		all_soft=[all_soft; corrsoft];
			
		
	end
	save([namestring '_allsubjects.mat'],'all_soft','all_corr');


elseif numfilters==1  %If only one filter variable
	filter1 = condition_data(:, filterstruct(1).filter_index); %grabs column values for filter 1
	for s = 1:length(f.subnums) % iterate through each subject
		label_array = {}; 
		data_matrix =[];
		subj = sprintf([f.subjtag '_%02d'],f.subnums(s)); %create subject name
		disp(['Working on subject ' subj]);
		eval(['dataset = f.data_struct.' subj ';']); %construct 'dataset' variable
		dataset=dataset(inds,:);
		offset = 140*(s-1);
		for i = 1:140
			if filter1(i+offset) == filterstruct(1).filter_vals 
				if label_col(i+offset) == 0 % if label associated with 0
					label_array{end + 1} = labelnames{1};
					data_matrix = [data_matrix; dataset(i, :)]; % nested inside if statement so that beta values only added to data_matrix
					% when there is an associated label at that index 
				elseif label_col(i+offset) == 1 % if label associated with 1
					label_array{end +1} = labelnames{2};
					data_matrix = [data_matrix; dataset(i, :)];
				end
			end
		end
		%keyboard

		[corracc,corrsoft]=younglab_svm_leavetwo(data_matrix, label_array, labelnames, ['svm_' namestring '_' subj '.mat']);
		all_corr=[all_corr; corracc];
		all_soft=[all_soft; corrsoft];
			
		
	end
	save([namestring '_allsubjects.mat'],'all_soft','all_corr');

else  % if no filter variables included
	for s = 1:length(f.subnums) % iterate through each subject
		label_array = {}; 
		subj = sprintf([f.subjtag '_%02d'],f.subnums(s)); %create subject name
		disp(['Working on subject ' subj]);
		eval(['dataset = f.data_struct.' subj ';']); %construct 'dataset' variable
		dataset=dataset(inds,:);
		offset = 140*(s-1);
		for i = 1:140
			if label_col(i+offset) == 0 % if label associated with value 0
				label_array{end + 1} = labelnames{1}; % 
			else % if label associated with value 1
				label_array{end +1} = labelnames{2};
			end
		end
		% keyboard

		[corracc,corrsoft]=younglab_svm_leavetwo(dataset, label_array, labelnames, ['svm_' namestring '_' subj '.mat']);
		all_corr=[all_corr; corracc];
		all_soft=[all_soft; corrsoft];
	end
	save([namestring '_allsubjects.mat'],'all_soft','all_corr');
end

		
