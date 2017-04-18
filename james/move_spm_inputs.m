cd('/home/younglw/VERBS/behavioural');

for thissub=3:47
	for runnum=1:6
		try
			f2=load(fullfile('/home/younglw/server/englewood/DIS_MVPA/DIS_MVPA/behavioural_pp',...
				['SAX_DIS_' sprintf('%02d',thissub) '.DIS.' num2str(runnum) '.mat']));
			spm_inputs_itemwise=f2.spm_inputs_itemwise;
			save(['SAX_DIS_' sprintf('%02d',thissub) '.DIS_verbs.' num2str(runnum) '.mat'],'spm_inputs_itemwise','-append');
		catch
			disp(['Could not transfer files for ' sprintf('%02d',thissub)]);
		end
	end
end
