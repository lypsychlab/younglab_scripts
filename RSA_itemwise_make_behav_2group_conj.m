function RSA_itemwise_make_behav_2group_conj(study,subj_tag, taskname,g1,g2,nitems,con_tag)
% see documentation for: RSA_itemwise_make_behav_2group
% conj stands for 'conjunction': this contrast places a 
% 0 if two items are in different groupings WITHIN g1 OR
% WITHIN g2, but not across g1-g2.


	root_dir=['/mnt/englewood/data/' study];
	cd(fullfile(root_dir,'behavioural'));



	subjects_cell={};sessions={};
	for thisnum=subj_nums
	    subjects_cell{end+1}=[subj_tag '_' sprintf('%02d',thisnum)];
	end
	% group_1=[1 2 6 7];
	% group_2=[3 4 8 9];

	for meow=1:length(subjects_cell)
		disp(['subject ' subjects_cell{meow}])
		% try
			load([subjects_cell{thiscell} '.' taskname '.1.mat']);
			behav_matrix=zeros(nitems,nitems);


			for it = 1:length(items)
				ind_1=items(it);
				thisitem=design(it);
				for it_2 = 1:length(items)
					ind_2=items(it_2);
					thatitem=design(it_2);
					if (ismember(thisitem,g1) && ismember(thatitem,g1)) 
						if (ismember(thisitem,g1(1:2)) && ismember(thatitem,g1(1:2))) || (ismember(thisitem,g1(3:4)) && ismember(thatitem,g1(3:4)))
							behav_matrix(ind_1,ind_2)=1;
						end
					end
					if (ismember(thisitem,g2) && ismember(thatitem,g2)) 
						if (ismember(thisitem,g2(1:2)) && ismember(thatitem,g2(1:2))) || (ismember(thisitem,g2(3:4)) && ismember(thatitem,g2(3:4)))
							behav_matrix(ind_1,ind_2)=1;
						end
					end
				end
			end % end outer item loop
			behav_matrix=tril(behav_matrix);
			save(['behav_matrix_' subjects_cell{meow} '_' con_tag '.mat'],'behav_matrix');
		% catch
		% 	disp(['Failed for subject ' subjs{s}])
		% 	continue
		% end
	end % end subject loop
end % end function