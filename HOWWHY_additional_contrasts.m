function HOWWHY_additional_contrasts(EXPERIMENT_ROOT_DIR,study,subj_tag,resdir, subnum)


addpath(genpath('/usr/public/spm/spm12'));


cd(fullfile(EXPERIMENT_ROOT_DIR,study,[subj_tag '_' sprintf('%02d',subnum)],'results',resdir));

addpath('/home/younglw/lab/scripts/');

load(fullfile(pwd,'SPM.mat'));
SPM

total_len=length(SPM.Vbeta);

if mod(subnum, 2) == 1  %if subject number is odd
	con_array = [0 0 1 1 1 0 0 1 1 0 0 0 1 1];  % How(0)/Why(1) condition order by run for odd subjs

	% HOW > WHY contrast
	con_array(con_array==1) = -1; %If WHY run, make negative
	con_array(con_array==0) = 1;  %If HOW run, make positive
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);

	disp('Adding contrast how v why')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'How vs Why', 'T', 'c', con_array',SPM.xX.xKXs); 
	% note the ' operator that transposes the vector, making it vertical

	% WHY > HOW contrast
	con_array = [0 0 1 1 1 0 0 1 1 0 0 0 1 1];

	con_array(con_array==1) = 1; %If WHY run, make positive
	con_array(con_array==0) = -1;  %If HOW run, make negative
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);

	disp('Adding contrast why v how')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'Why vs How', 'T', 'c', con_array',SPM.xX.xKXs); 
	% note the ' operator that transposes the vector, making it vertical

	%HARM/HOW > PURITY/HOW

	con_array = [1 1 0 0 0 1 1 0 0 1 1 1 0 0]  % How(0)/Why(1) values switched because only looking at HOW runs
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % 14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);
	
	
	for trial = 1:total_len % for 1 through 154 (length of vbeta and con_array)
		if con_array(trial) == 1 % if trial is a how trial

			if not(isempty(strfind(SPM.Vbeta(trial).descrip, 'harm'))) % if strfind returns an index, then trail is harm trial
				con_array(trial) = 1;
			elseif not(isempty(strfind(SPM.Vbeta(trial).descrip, 'purity'))) % if strfind returns an index, then trail is purity trial
				con_array(trial) = -1;
			else                          
				con_array(trial) = 0;  % assigns value of 0 for neutral trials in HOW condition

			end

		else
			continue

		end

	end
	
	disp('Adding contrast harm/how v purity/how')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'harm/how vs purity/how', 'T', 'c', con_array',SPM.xX.xKXs);


	%PURITY/HOW > HARM/HOW
	
	for trial = 1:total_len % for 1 through 154 (length of vbeta)
		if con_array(trial) == 1 % now assigning negative 1 to harm trials previously labelled with positive 1
			con_array(trial) = -1;
		elseif con_array(trial) == -1 % now assigning positive 1 to purity trials previously labelled with negative 1
			con_array(trial) = 1;
		else                          
			continue 

		end

	end
	
	disp('Adding contrast purity/how v harm/how')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'purity/how vs harm/how', 'T', 'c', con_array',SPM.xX.xKXs);

	%HARM/WHY > PURITY/WHY
	con_array = [0 0 1 1 1 0 0 1 1 0 0 0 1 1]  % Only looking at WHY runs
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % 14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);
	
	
	for trial = 1:total_len % for 1 through 154 (length of vbeta and con_array)
		if con_array(trial) == 1 % if trial is a WHY trial

			if not(isempty(strfind(SPM.Vbeta(trial).descrip, 'harm'))) % if strfind returns an index, then trial is harm trial
				con_array(trial) = 1;
			elseif not(isempty(strfind(SPM.Vbeta(trial).descrip, 'purity'))) % if strfind returns an index, then trial is purity trial
				con_array(trial) = -1;
			else                          
				con_array(trial) = 0;  % assigns value of 0 for neutral trials in HOW condition

			end

		else
			continue

		end

	end
	
	disp('Adding contrast harm/why v purity/why')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'harm/why vs purity/why', 'T', 'c', con_array',SPM.xX.xKXs);

	%PURITY/WHY > HARM/WHY
	for trial = 1:total_len % for 1 through 154 (length of vbeta)
		if con_array(trial) == 1 % now assigning negative 1 to harm trials previously labelled with positive 1
			con_array(trial) = -1;
		elseif con_array(trial) == -1 % now assigning positive 1 to purity trials previously labelled with negative 1
			con_array(trial) = 1;
		else                          
			continue 

		end

	end
	disp('Adding contrast purity/why v harm/why')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'purity/why vs harm/why', 'T', 'c', con_array',SPM.xX.xKXs);



else 
	con_array = [1 1 0 0 0 1 1 0 0 1 1 1 0 0]  % How(0)/Why(1) condition order by run for even subjs

	% HOW > WHY contrast
	con_array(con_array==1) = -1; %If WHY run, make negative
	con_array(con_array==0) = 1;  %If HOW run, make positive
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals); %concatenates constant vals to end of con_array

	disp('Adding contrast how v why')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'How vs Why', 'T', 'c', con_array',SPM.xX.xKXs); 
	% note the ' operator that transposes the vector, making it vertical

	% WHY > HOW contrast
	con_array = [1 1 0 0 0 1 1 0 0 1 1 1 0 0]

	con_array(con_array==1) = 1; %If WHY run, make positive
	con_array(con_array==0) = -1;  %If HOW run, make negative
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; %14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);

	disp('Adding contrast why v how')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'Why vs How', 'T', 'c', con_array',SPM.xX.xKXs); 
	% note the ' operator that transposes the vector, making it vertical

	


	%HARM/HOW > PURITY/HOW

	con_array = [0 0 1 1 1 0 0 1 1 0 0 0 1 1]  % How(0)/Why(1) values switched because only looking at HOW runs
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % 14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);
	
	
	for trial = 1:total_len % for 1 through 154 (length of vbeta and con_array)
		if con_array(trial) == 1 % if trial is a how trial

			if not(isempty(strfind(SPM.Vbeta(trial).descrip, 'harm'))) % if strfind returns an index, then trail is harm trial
				con_array(trial) = 1;
			elseif not(isempty(strfind(SPM.Vbeta(trial).descrip, 'purity'))) % if strfind returns an index, then trail is purity trial
				con_array(trial) = -1;
			else                          
				con_array(trial) = 0;  % assigns value of 0 for neutral trials in HOW condition

			end

		else
			continue

		end

	end
	disp('Adding contrast harm/how v purity/how')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'harm/how vs purity/how', 'T', 'c', con_array',SPM.xX.xKXs);


	%PURITY/HOW > HARM/HOW
	
	for trial = 1:total_len % for 1 through 154 (length of vbeta)
		if con_array(trial) == 1 % now assigning negative 1 to harm trials previously labelled with positive 1
			con_array(trial) = -1;
		elseif con_array(trial) == -1 % now assigning positive 1 to purity trials previously labelled with negative 1
			con_array(trial) = 1;
		else                          
			continue 

		end

	end
	
	disp('Adding contrast purity/how v harm/how')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'purity/how vs harm/how', 'T', 'c', con_array',SPM.xX.xKXs);

	%HARM/WHY > PURITY/WHY
	con_array = [1 1 0 0 0 1 1 0 0 1 1 1 0 0]  % Only looking at WHY runs
	con_array = repelem(con_array, 10); %for each value in array, repeat it 10 times for 10 trials per run
	constant_vals = [0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % 14 zeros for run constants to be appended to end of array
	con_array = cat(2, con_array, constant_vals);
	
	
	for trial = 1:total_len % for 1 through 154 (length of vbeta and con_array)
		if con_array(trial) == 1 % if trial is a WHY trial

			if not(isempty(strfind(SPM.Vbeta(trial).descrip, 'harm'))) % if strfind returns an index, then trial is harm trial
				con_array(trial) = 1;
			elseif not(isempty(strfind(SPM.Vbeta(trial).descrip, 'purity'))) % if strfind returns an index, then trial is purity trial
				con_array(trial) = -1;
			else                          
				con_array(trial) = 0;  % assigns value of 0 for neutral trials in HOW condition

			end

		else
			continue

		end

	end
	disp('Adding contrast harm/why v purity/why')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'harm/why vs purity/why', 'T', 'c', con_array',SPM.xX.xKXs);

	%PURITY/WHY > HARM/WHY
	for trial = 1:total_len % for 1 through 154 (length of vbeta)
		if con_array(trial) == 1 % now assigning negative 1 to harm trials previously labelled with positive 1
			con_array(trial) = -1;
		elseif con_array(trial) == -1 % now assigning positive 1 to purity trials previously labelled with negative 1
			con_array(trial) = 1;
		else                          
			continue 

		end

	end
	disp('Adding contrast purity/why v harm/why')
	SPM.xCon(end+1)=spm_FcUtil('Set', 'purity/why vs harm/why', 'T', 'c', con_array',SPM.xX.xKXs);

end
%end

clear con_array EXPERIMENT_ROOT_DIR study subj_tag subnum resdir trial total_len constant_vals
save('SPM.mat');
spm_contrasts_pleiades(SPM);
disp('Done')	





		