function [corracc,corrsoft] = younglab_svm_leavetwo(dataset,labeled_data,cnames,fname)
%younglab_svm:
%- performs leave-two-out classification with fitcsvm() and predict().
%- testing sets consist of every combination of 1 member of class 1 with 1 member of class 2
%
%dataset: t x v matrix, where t=number of trials and v=number of voxels
%labeled_data: t x 1 cell array, where t=number of trials 
%and labeled_data{t} = the correct class label for trial t
%cnames: 1 x 2 cell array, cnames{c} = the name of the cth class
%fname: output filename

	

	recode_labels=zeros(size(dataset,1),1); %holds CORRECT 0/1 classes
	outputs = [];soft_outputs=[];

	for t=1:size(dataset,1)
        if strcmp(labeled_data{t},cnames{2}) %if this item is a member of class 2
			recode_labels(t)=1; %gets numeric code 1 (class 1 = 0)
        end
    end

    class1=find(recode_labels==0); %indices of trials in class 1
	class2=find(recode_labels==1);


    for t=1:length(class1)
    	tval=class1(t);
    	testing_1=dataset(tval,:); % first one left out (from class 1)

    	for t2=1:length(class2)
	%define training and testing groups
			t2val=class2(t2);
			testing_2=dataset(t2val,:); % second one left out (from class 2)
			testing=[testing_1;testing_2];  %stack them to run model on both

			train_inds=find(~ismember([1:size(dataset,1)],[tval t2val])); %inds of everything NOT left out
			training=dataset(train_inds,:);
			
	        
	        labeled_training = labeled_data;
	        labeled_training(t,:)=[];%remove t's label from class labels
	        labeled_training(t2,:)=[];%same with t2

		%for each training/testing set: fit the svm model and then test on the left-out one
			svmmodel = fitcsvm(training,labeled_training,'KernelFunction','linear',...
				'Standardize',true,'ClassNames',cnames);
			[labels,softscores] = predict(svmmodel,testing);
			%labels returns the label for each trial in testing
			%softscores: t x 2 matrix of soft scores, where softscores(t,1) contains the score for the trial
			%being classified, for the first class
			class1ness=softscores(:,1);
			output_class1=find(class1ness==max(class1ness)); %which of the two is more class-1-ish?
			if output_class1==1 %i.e. the actual class 1 item was the more class-1-ish
				soft_outputs=[soft_outputs;1];
			else
				soft_outputs=[soft_outputs;0];
			end
            
			is_correct=(strcmp(labels{1},cnames{1}))&&(strcmp(labels{2},cnames{2}));
			% 1 if there are no differences (i.e. the labels were correctly predicted)
			if is_correct
				outputs=[outputs;1];
			else
				outputs=[outputs;0];
			end

		end
	end

	corracc=(length(find(outputs==1)))/length(outputs);
	corrsoft=(length(find(soft_outputs==1)))/length(soft_outputs);
	save(fname,'dataset','labeled_data','outputs','soft_outputs','recode_labels','corracc','corrsoft','cnames');
	
end
