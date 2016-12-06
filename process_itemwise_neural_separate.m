function process_itemwise_neural_separate(study,subj_tag,resdir,task,numtasks,sub_nums,items,roi_ind,intag,outtag)

	excluded=[14 18 24 28 29 30 31 32];
	for thissub=1:length(sub_nums)
		% if ismember(sub_nums(thissub),excluded)
		% 	continue
		% end
		sub=[subj_tag '_' sprintf('%02d',sub_nums(thissub))];
		% disp(['Subject ' sub]);
		rootdir='/mnt/englewood/data';
		cd(fullfile(rootdir,study,sub,'results',resdir));
		load(['itemwise_neural_' intag '.mat']);

		behav=[]; all_items=[];
		cd(fullfile(rootdir,study,'behavioural'));
		for T=1:numtasks
			B=load([sub '.' task '.' num2str(T) '.mat']);
			behav=[behav; B.key];
			all_items=B.items;
			design=B.design;
			clear B;
		end

		% sorted_behav=zeros(length(behav),1);
		% for it=1:length(behav)
		% 	sorted_behav(all_items(it)) = behav(it);
		% end

		% this is in item order:
		item_struct(thissub).neural = OUT(:,roi_ind); % items x 1 vector; BOLD per item
		% the following are in subject-specific order:
		item_struct(thissub).behavior = behav; % items x 1 vector; wrongness judgment per item
		item_struct(thissub).design = design; % items x 1 vector: design coding per item
		item_struct(thissub).items = all_items; % items x 1 vector: item number 
		clear OUT sorted_behav;
	end

	cd(fullfile(rootdir,study,'behavioural'));
	thisroi = rois{roi_ind};

	save(['processed_itemwise_neural_' thisroi '_' outtag '.mat'],'item_struct');
	thisroi = rois{roi_ind};

	brain_x_behav = zeros(items,4);
	 
	for thisit=1:items % for each ITEM NUMBER
		disp(['Item ' num2str(thisit)]);
		acc_behavior_data=[];
		int_behavior_data=[];
		neural_acc=[]; neural_int=[];
		for thissub = 1:length(sub_nums)
			if ismember(sub_nums(thissub),excluded)
				continue
			end
			sub=[subj_tag '_' sprintf('%02d',sub_nums(thissub))];
			it=find(item_struct(thissub).items==thisit); % which index is it at, for this subject?
			disp(['Subject: ' sub '; Item index: ' num2str(it)]);
			des=item_struct(thissub).design(it); % which category is the item in?
			% it's never going to switch domains across participants - just accidentality/intentionality
				if ismember(des,[1 2]) % if it's accidental
					neural_acc = [neural_acc item_struct(thissub).neural(thisit)];
					acc_behavior_data = [acc_behavior_data item_struct(thissub).behavior(it)];
				else if ismember(des,[6 7]) % otherwise, if it's intentional
					neural_int = [neural_int item_struct(thissub).neural(thisit)];
					int_behavior_data = [int_behavior_data item_struct(thissub).behavior(it)];
				else if ismember(des,[3 4])
					neural_acc = [neural_acc item_struct(thissub).neural(thisit)];
					acc_behavior_data = [acc_behavior_data item_struct(thissub).behavior(it)];
				else if ismember(des,[8 9])
					neural_int = [neural_int item_struct(thissub).neural(thisit)];
					int_behavior_data = [int_behavior_data item_struct(thissub).behavior(it)];
				end
			end
		end
		end
		acc_behavior_data=nanmean(acc_behavior_data); int_behavior_data=nanmean(int_behavior_data);
		diffscore=int_behavior_data-acc_behavior_data;
		neural_acc_mean=nanmean(neural_acc);
		neural_int_mean=nanmean(neural_int);

		brain_x_behav(thisit,5)=diffscore;
		brain_x_behav(thisit,1)=neural_acc_mean;
		brain_x_behav(thisit,2)=acc_behavior_data;
		brain_x_behav(thisit,3)=neural_int_mean;
		brain_x_behav(thisit,4)=int_behavior_data;
	end

	colinfo={'Mean BOLD' 'Moral wrongness (Acc)' 'Moral wrongness (Int)' 'Intent effect'};
	cd(fullfile(rootdir,study,'behavioural'));
	save(['processed_itemwise_neural_' thisroi '_' outtag '.mat'],'brain_x_behav','item_struct','colinfo','-append');







end


