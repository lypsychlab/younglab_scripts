function convert_TR(study,subj,tname,TR)
	rootdir='/home/younglw/lab';
	cd(fullfile(rootdir,study,'behavioural'));
	d=dir([subj '.' tname '*mat']);

	for fl = 1:length(d)
		load(d(fl).name);
		for inp=1:length(spm_inputs)
			spm_inputs(inp).ons=round(spm_inputs(inp).ons./TR);
			spm_inputs(inp).dur=round(spm_inputs(inp).dur./TR);
		end
		save(d(fl).name,'spm_inputs','-append');
	end
end