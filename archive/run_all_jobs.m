function run_all_jobs(tagnames,splitgroup)

DIS_itemwise_job_pleiades(tagnames);
estimate_spm_pleiades('/home/younglw/server/englewood/mnt/englewood/data','PSYCH-PHYS',tagnames);

	if splitgroup == 1
		DIS_itemwise_job_NT_pleiades(tagnames);
		DIS_itemwise_job_ASD_pleiades(tagnames);
		tagsnt={};
		tagsasd={};
		for t=1:length(tagnames)
			tagsnt{end+1}=[tagnames{t} '_NT'];
			tagsasd{end+1}=[tagnames{t} '_ASD'];
		end
		estimate_spm_pleiades('/home/younglw/server/englewood/mnt/englewood/data','PSYCH-PHYS',tagsnt);
		estimate_spm_pleiades('/home/younglw/server/englewood/mnt/englewood/data','PSYCH-PHYS',tagsasd);

	end

end