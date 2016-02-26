function younglab_svm(dataset,labeled_data,cnames,fname)
%younglab_svm:
%- performs leave-one-out classification with fitcsvm() and predict()
%
%dataset: t x v matrix, where t=number of trials and v=number of voxels
%labeled_data: t x 1 cell array, where t=number of trials 
%and labeled_data{t} = the correct class label for trial t
%cnames: 1 x 2 cell array, cnames{c} = the name of the cth class
%fname: output filename

	output_labels={};
	recode_labels=zeros(length(dataset),1); %holds CORRECT 0/1 classes
	output_labels_recode=zeros(length(dataset),1); %holds PREDICTED 0/1 classes
	all_softscores=[];

	for t=1:length(dataset)
        if strcmp(labeled_data{t},cnames{2}) %if this item is a member of class 2
			recode_labels(t)=1; %gets numeric code 1 (class 1 = 0)
        end
	%define training and testing groups
		testing=dataset(t,:);
		train_inds=find([1:length(dataset)] ~= t);
		training=dataset(train_inds,:);
		
        
        labeled_training = labeled_data;
        labeled_training(t,:)=[];%remove t's label from class labels
        labeled_training
        length(training)
        length(labeled_training)
	%for each training/testing set: fit the svm model and then test on the left-out one
		svmmodel = fitcsvm(training,labeled_training,'KernelFunction','rbf','Standardize',true,'ClassNames',cnames);
		[labels,softscores] = predict(svmmodel,testing);
		%labels returns the label for each trial in testing
		%softscores: t x 2 matrix of soft scores, where softscores(t,1) contains the score for the trial
		%being classified, for the first class
		output_labels{end+1}=labels;
		all_softscores=[all_softscores;softscores];
		if strcmp(labels,cnames{2})
			output_labels_recode(t)=1;
		end
	end

	class1=find(recode_labels==0); %indices of trials in class 1
	class2=find(recode_labels==1);
	disp(['Number of trials in ' cnames{1} ' class: ' num2str(length(class1))]);
	disp(['Number of trials in ' cnames{2} ' class: ' num2str(length(class2))]);
	class1_out = output_labels_recode(class1); %indices of those which are truly class 1
	class2_out = output_labels_recode(class2);
	correct_1 = find(class1_out==0); %out of those, which match their original class?
	incorrect_1 = find(class1_out==1); %how many class 1 items were incorrectly classified as class 2?
	correct_2 = find(class2_out==1);
	incorrect_2 = find(class2_out==0); %how many class 2 items were incorrectly classified as class 1?
	disp(['Class ' cnames{1} ' correctly classified (%): ' num2str(100*length(correct_1)/length(class1))]);
	disp(['Class ' cnames{1} ' incorrectly classified (%): ' num2str(100*length(incorrect_1)/length(class1))]);
	disp(['Class ' cnames{2} ' correct classification (%): ' num2str(100*length(correct_2)/length(class2))]);
	disp(['Class ' cnames{2} ' incorrectly classified (%): ' num2str(100*length(incorrect_2)/length(class2))]);


	prop_correct_as1=length(correct_1)/length(class1);
	prop_incorrect_as1=length(incorrect_2)/length(class2);
	save(fname,'dataset','labeled_data','output_labels','all_softscores','cnames');
end
