default_runs = [5 7 9 11 13 15 17 23 25 27 29 31 33 35]; 

odd_ball_runs1 = [7 9 11 13 15 17 19 25 27 29 31 33 35 37];
% subjects # 4,22, 29

odd_ball_runs2 = [5 7 9 11 13 15 17 25 27 29 31 33 35 37];
% subjects # 6, 8, 9, 11
%


for subj_num = 21:29


	if ismember(subj_num, [4 22 29])
		subj_name = sprintf('YOU_HOWWHY_%02d', subj_num);
		younglab_model_spm12_harmpur_unsmooth('HOWWHY_Runwise', subj_name,'HOWWHY', odd_ball_runs1);

	else if ismember(subj_num, [6 8 9 11])
		subj_name = sprintf('YOU_HOWWHY_%02d', subj_num);
		younglab_model_spm12_harmpur_unsmooth('HOWWHY_Runwise', subj_name,'HOWWHY', odd_ball_runs2);

	else
		subj_name = sprintf('YOU_HOWWHY_%02d', subj_num);
		younglab_model_spm12_harmpur_unsmooth('HOWWHY_Runwise', subj_name,'HOWWHY', default_runs);
	end
	end
end

