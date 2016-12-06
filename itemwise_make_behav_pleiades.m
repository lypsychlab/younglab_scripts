function itemwise_make_behav_pleiades(root_dir,study,subj_tag,tname,subj_nums,numruns,numitems,g1,con_tag)
% itemwise_make_behav:
% makes a similarity matrix of 1's and 0's, assigning pairwise similarities between items in g1 as 1 and all others as 0

	root_dir=fullfile(root_dir,study);

	cd(fullfile(root_dir,'behavioural'));


	allsubjects={};sessions={};

	for thisnum=subj_nums
	    allsubjects{end+1}=[subj_tag '_' sprintf('%02d',thisnum)];
	end


	for this_sub=1:length(allsubjects)
		disp(['Subject ' allsubjects{this_sub}])
		if exist(['behav_matrix_' allsubjects{this_sub} '_' con_tag '.mat'])>0
			disp(['Behavioural matrices for subject ' allsubjects{this_sub} ' already exist! Continuing to next subject...']);
			continue
		end
		all_design=[];
		for rn=1:numruns
			f=load([allsubjects{this_sub} '.' tname '.' num2str(rn) '.mat']);
			all_design=[all_design f.design_run];
			clear f;
		end

			load([allsubjects{this_sub} '.' tname '.1.mat']);
			design=all_design;
			behav_matrix=zeros(numitems,numitems);


			for it = 1:length(items)
				ind_1=items(it);
				thisitem=design(it);
				for it_2 = 1:length(items)
					ind_2=items(it_2);
					thatitem=design(it_2);
					if (ismember(thisitem,g1) && ismember(thatitem,g1))
						behav_matrix(ind_1,ind_2)=1;
					end
				end
			end % end outer item loop
			behav_matrix=tril(behav_matrix);
		
			save(['behav_matrix_' allsubjects{this_sub} '_' con_tag '.mat'],'behav_matrix');
	end % end subject loop
end % end function