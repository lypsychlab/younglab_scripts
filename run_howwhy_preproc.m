function run_howwhy_preproc(subs,tempflag,spatflag)

study='HOWWHY_Runwise';
for sub = subs
	sub=sprintf('YOU_HOWWHY_%02d',sub);
% rmpath(genpath('/usr/public/spm/spm8'));
% addpath(genpath('/usr/public/spm/spm12'))
	if tempflag==1
		younglab_preproc_temporal_spm12_pleiades(study,sub);
	end
	if strcmp(spatflag,'full')
		younglab_preproc_spatial_runwise_spm12_pleiades(study,sub);
	else if strcmp(spatflag,'smooth')
		younglab_preproc_spatial_runwise_spm12_pleiades(study,sub,4);
	else if strcmp(spatflag,'normalize')
		younglab_preproc_spatial_runwise_spm12_pleiades(study,sub,2);
	end
	end
	end
end

end