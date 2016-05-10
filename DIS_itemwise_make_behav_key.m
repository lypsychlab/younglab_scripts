function DIS_itemwise_make_behav_key(subj_nums,con_tag)
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


	% contrast_names={'harm-purity' 'phys-psych-incest-pathogen' 'int-acc' 'int-acc-HARM' 'int-acc-PURITY' 'int-acc-V-harm-purity'};

	kitty={};sessions={};
% 	subj_nums=[3:20 22:24 27:35 38:42 44:47];
    % subj_nums=[3];
	for poop=1:length(subj_nums)
	    kitty{end+1}=['SAX_DIS_' sprintf('%02d',subj_nums(poop))];
	end
	% group_1=[1 2 6 7];
	% group_2=[3 4 8 9];

	for meow=1:length(kitty)
		disp(['Subject ' kitty{meow}])
		% try
		% if exist(['behav_matrix_' kitty{meow} '_' con_tag '.mat'])>0
		% 	disp(['Behavioural matrices for subject ' kitty{meow} ' already exist! Continuing to next subject...']);
		% 	continue
		% end

		missing_flag=0;
		all_key=[];all_design=[];
		for rn=1:6
			f=load([kitty{meow} '.DIS_verbs.' num2str(rn) '.mat']);
			if ismember(0,f.key)
				missing_flag=1;
			end
			all_key=[all_key f.key];
			all_design=[all_design f.design_run];
			clear f;
		end


		if missing_flag == 1
			disp(['Missing response info for subject ' kitty{meow} '! Continuing to next subject...']);
			continue
		end

			load([kitty{meow} '.DIS_verbs.1.mat']);
			design=all_design;
			behav_matrix=zeros(48,48);


			for it = 1:length(items)
				ind_1=items(it);
				thisitem=design(it);
				for it_2 = 1:length(items)
					ind_2=items(it_2);
					thatitem=design(it_2);
				
					switch abs(all_key(it)-all_key(it_2))
					case 0 %maximum similarity
						simil = 1;
					case 1
						simil = 0.67;
					case 2
						simil = 0.33;
					case 3
						simil=0; %maximum dissimilarity
					end
					behav_matrix(ind_1,ind_2)=simil;
				end
			end % end outer item loop
			behav_matrix=behav_matrix(1:48,1:48);
			behav_matrix=tril(behav_matrix);
			if strcmp(con_tag,'HvP_H_48')
				behav_matrix1=behav_matrix;
				save(['behav_matrix_' kitty{meow} '_' con_tag '.mat'],'behav_matrix1');
			else if strcmp(con_tag,'HvP_P_48')
				behav_matrix2=behav_matrix;
				save(['behav_matrix_' kitty{meow} '_' con_tag '.mat'],'behav_matrix2');
			else
				save(['behav_matrix_' kitty{meow} '_' con_tag '.mat'],'behav_matrix');
			end
		% catch
		% 	disp(['Failed for subject ' subjs{s}])
		% 	continue
		% end
	end % end subject loop
end % end function