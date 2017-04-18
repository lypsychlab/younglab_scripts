function run_all_jobs(tagnames,splitgroup)
% 0 for only all subs, 1 for only ASD/NT, 2 for both
	% if mod(splitgroup,2) == 0
	% 	disp('Running jobs for all subjects...')
	% 	DIS_itemwise_job_pleiades(tagnames);
	% 	estimate_spm_pleiades('/home/younglw/lab/server/englewood/mnt/englewood/data','PSYCH-PHYS',tagnames);

	% splitgroup = splitgroup - 1;
	% splitgroup
	if splitgroup == 1
		disp('Running jobs for ASD/NT subjects...')
		DIS_2samptest_job(tagnames);
		estimate_spm_pleiades_ASD_NT('/home/younglw/lab/server/englewood/mnt/englewood/data','PSYCH-PHYS',tagnames);

	end

end