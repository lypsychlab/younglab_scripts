function DIS_itemwise_make_behav_interaction(con_tag)
%sample call: DIS_itemwise_make_behav([1 2 6 7],[3 4 8 9],'HvP')

% - harm vs purity DONE
% (1 2 6 7) vs (3 4 8 9)
% - phys-harm vs psych-harm vs incest vs pathogen DONE
% (1 6) vs (2 7) vs (3 8) vs (4 9)
% - intent vs accident DONE
% (6 7 8 9 10) vs (1 2 3 4 5)
% - intent vs accident - harm only DONE
% (6 7) vs (1 2)
% - intent vs accident - purity only DONE
% (8 9) vs (3 4)
% - intent vs accident X harm vs purity interaction 
% (6 7 8 9/1 2 3 4) x (1 2 6 7/3 4 8 9)
% 2 for harm&int [6 7], 1 for harm xor int [1 2 8 9], 0 otherwise


% 1: phys acc
% 2: psych acc
% 3: incest acc
% 4: pathogen acc
% 5: neutral acc
% 6: phys int
% 7: psych int
% 8: incest int
% 9: pathogen int
% 10: neutral int



	root_dir='/mnt/englewood/data/PSYCH-PHYS';
	cd(fullfile(root_dir,'behavioural'));


	contrast_names={'harm-purity' 'phys-psych-incest-pathogen' 'int-acc' 'int-acc-HARM' 'int-acc-PURITY' 'int-acc-V-harm-purity'};

	kitty={};sessions={};
	% subj_nums=[3:20 22:24 27:35 38:42 44:47];
	subj_nums=[3];
	
	for poop=subj_nums
	    kitty{end+1}=['SAX_DIS_' sprintf('%02d',poop)];
	end
	% group_1=[1 2 6 7];
	% group_2=[3 4 8 9];

	for meow=1:length(kitty)
		disp(['subject ' kitty{meow}])
		% try
			load([kitty{meow} '.DIS_verbs.1.mat']);
			behav_matrix=ones(60,60);


			for it = 1:length(items)
				ind_1=items(it);
				thisitem=design(it);
				for it_2 = 1:length(items)
					ind_2=items(it_2);
					thatitem=design(it_2);
					if (ismember(thisitem,[3 4 8 9]) && ismember(thatitem,[1 2 6 7])) || (ismember(thisitem,[1 2 6 7]) && ismember(thatitem,[3 4 8 9]))
						behav_matrix(ind_1,ind_2)=0;
					else if (ismember(thisitem,[6 7]) && ismember(thatitem,[1 2])) || (ismember(thisitem,[1 2]) && ismember(thatitem,[6 7]))
						behav_matrix(ind_1,ind_2)=0;
					else if ismember(thisitem,[5 10]) || ismember(thatitem,[5 10])
						behav_matrix(ind_1,ind_2)=0;
					end
					end
				end
			end % end outer item loop
			behav_matrix=tril(behav_matrix);
			save(['behav_matrix_' kitty{meow} '_' con_tag '.mat'],'behav_matrix');
		% catch
		% 	disp(['Failed for subject ' subjs{s}])
		% 	continue
		% end
	end % end subject loop
end % end function