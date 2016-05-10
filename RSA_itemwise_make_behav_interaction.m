function RSA_itemwise_make_behav_interaction(study,subj_tag,subj_nums, taskname,g1,g2,sg1,sg2,neut,nitems,con_tag)
% see documentation for: RSA_itemwise_make_behav_2group
% this version is designed to produce a 2x2 interaction design matrix, where
% g1 and g2 are larger groupings, and g1 is split by the second factor into subgroups sg1 and sg2.
% neut indicates neutral condition to be excluded.

	root_dir=['/mnt/englewood/data/' study];
	cd(fullfile(root_dir,'behavioural'));



	subjects_cell={};
	
	for thisnum=subj_nums
	    subjects_cell{end+1}=[subj_tag '_' sprintf('%02d',thisnum)];
    end
%     subjects_cell
	% group_1=g1;
	% group_2=g2;

	for thiscell=1:length(subjects_cell)
		disp(['subject ' subjects_cell{thiscell}])
		try
			load([subjects_cell{thiscell} '.' taskname '.1.mat']);
			behav_matrix=ones(nitems,nitems);


			for it = 1:length(items)
				ind_1=items(it);
				thisitem=design(it);
				for it_2 = 1:length(items)
					ind_2=items(it_2);
					thatitem=design(it_2);
					if (ismember(thisitem,g2) && ismember(thatitem,g1)) || (ismember(thisitem,g1) && ismember(thatitem,g2))
						behav_matrix(ind_1,ind_2)=0;
					else if (ismember(thisitem,sg1) && ismember(thatitem,sg2)) || (ismember(thisitem,sg2) && ismember(thatitem,sg1))
						behav_matrix(ind_1,ind_2)=0;
					else if ismember(thisitem,neut) || ismember(thatitem,neut)
						behav_matrix(ind_1,ind_2)=0;
					end
					end
				end
			end % end outer item loop
			behav_matrix=tril(behav_matrix);
			save(['behav_matrix_' subjects_cell{thiscell} '_' con_tag '.mat'],'behav_matrix');
            end
		catch
			disp(['Failed for subject ' subjects_cell{thiscell}])
			continue
		end
	end % end subject loop
end % end function