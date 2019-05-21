
save_dir='/home/younglw/VERBS/behavioural/';

exclude=[21 25 26 36 37 43];

for j=3:47 %loop subjects
	if ismember(j,exclude)
		continue
	else
	for k=1:6 %loop runs
		sub=num2str(j);
		rn=num2str(k);
		disp(['Subject ' sub ' Run ' rn]);
	
		MVT=load(sprintf(['/home/wasserem/verbs_behavioural/SAX_DIS_' '%02d' '.DIS_mvt.' '%02d' '.mat'],j,k));
		UR=MVT.user_regressors;

		if any(design==0)
			continue;
		end

		for reg=1:length(UR)
			user_regressors(reg).name=UR(reg).name;
			user_regressors(reg).ons=[];
		end

		for n=1:length(design) %for every value in the designs vector
			%grab the appropriate onset value - data_matrix{j,k,3}(n) 
			%and add it into the spm_inputs.onset array at the correct location - 1,data_matrix(j,k,9)(n)
			% spm_inputs(design(n)).ons = [spm_inputs(design(n)).ons; data_matrix{j,k,3}(n)];
			user_regressors(design(n)).ons = [user_regressors(design(n)).ons UR.ons];
		end

		% for m=1:length(cond_names)
		% 	spm_inputs(m).dur = repmat([11],length(spm_inputs(m).ons),1);
		% end

		save(fullfile(save_dir,['SAX_DIS_' sprintf('%02d',j) '.DIS_verbs.' rn '.mat']), 'user_regressors','-append');
	end
	end
end