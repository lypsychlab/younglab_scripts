function RSA_itemwise_make_behav_smallgroup(study,subj_tag,subj_nums, taskname,g1,g2,starts,nitems,con_tag)
% RSA_itemwise_make_behav_smallgroup(study,subj_tag,taskname,g1,g2,con_tag)
% - generates design matrices to be used in RSA searchlight analysis.
% This version is designed to run a 2-condition contrast, with the condition
% codings indicated in g1 and g2.
%
% Parameters:
% - study: study directory string
% - subj_tag: prefix on subject directory names
% - taskname: name of behavioural .mat files to source
% - g1, g2: condition groupings to create contrast
% - starts: starting and ending indices for looping
% - nitems: size of matrix to be produced (if itemwise, should match total # of items)
% - con_tag: name of contrast (used to name the output .mat file)
%
% Output:
% - behav_matrix_[subject]_[con_tag].mat: contains behav_matrix variable,
% which is the design matrix for this contrast
%
%sample call: RSA_itemwise_make_behav('PSYCH-PHYS','SAX_DIS',[3:14],'DIS',[1 2 6 7],[3 4 8 9],'HvP')
% [1 2 6 7] are harm, [3 4 8 9] are purity


	root_dir=['/mnt/englewood/data/' study];
	cd(fullfile(root_dir,'behavioural'));


	subjects_cell={};sessions={};
% 	subj_nums=[3:20 22:24 27:35 38:42 44:47];
	for thisnum=subj_nums
	    subjects_cell{end+1}=[subj_tag '_' sprintf('%02d',thisnum)];
	end
	% group_1=[1 2 6 7];
	% group_2=[3 4 8 9];

	for thiscell=1:length(subjects_cell)
		disp(['subject ' subjects_cell{thiscell}])
		% try
			load([subjects_cell{thiscell} '.' taskname '.1.mat']);
			behav_matrix=zeros(nitems,nitems);


			for it = starts(1):starts(2)
				ind_1=items(it);
				thisitem=design(it);
				for it_2 = starts(1):starts(2)
					ind_2=items(it_2);
					thatitem=design(it_2);
					if (ismember(thisitem,g1) && ismember(thatitem,g1)) || (ismember(thisitem,g2) && ismember(thatitem,g2))
						behav_matrix(ind_1,ind_2)=1;
					end
				end
			end % end outer item loop
			behav_matrix=tril(behav_matrix);
			save(['behav_matrix_' subjects_cell{thiscell} '_' con_tag '.mat'],'behav_matrix');
		% catch
		% 	disp(['Failed for subject ' subjs{s}])
		% 	continue
		% end
	end % end subject loop
end % end function