function pull_contrasts(matpath)
% pull_contrasts(matpath)
% - matpath: path to SPM.mat file, minus the filename itself
	f = load(fullfile(matpath,'SPM.mat'));
	betanames = cell(1,length(f.SPM.Vbeta));
	for i=1:length(f.SPM.Vbeta)
		betanames{i}=f.SPM.Vbeta(i).descrip(23:end);
		betanames{i}=strrep(betanames{i},'*bf(1)','');
		betanames{i}=regexprep(betanames{i},'Sn\(\d\)','');
	end
	clear f;
	save(fullfile(matpath,'SPM_betas.mat'),'betanames');
end