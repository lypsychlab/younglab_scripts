function getFWHM(study,tgs,outtag,voxsize)
% getFWHM():
% obtain full width half max values to use with 3dClustSim
% 
% study: name of study
% tgs: cell array of subdirectory names in .../RandomEffects
% outtag: string to save results (should start with underscore)
% voxsize: size of your voxels in mm
rootdir = '/home/younglw/lab/';
varnames={'Regressor' 'FWHMx' 'FWHMy' 'FWHMz'};
fwhm=cell(length(tgs),4);
for t=1:length(tgs)
	disp(['Grabbing FWHM for ' tgs{t} '...']);
	cd(fullfile(rootdir,study,'RandomEffects',tgs{t}));
	f=load('SPM.mat');
	fwhm{t,1}=tgs{t};
	fwhm{t,2}=f.SPM.xVol.FWHM(1)*voxsize;
	fwhm{t,3}=f.SPM.xVol.FWHM(2)*voxsize;
	fwhm{t,4}=f.SPM.xVol.FWHM(3)*voxsize;
	clear f;
end
try
	cd(fullfile(rootdir,study,'results'));
catch
	mkdir(fullfile(rootdir,study,'results'));
	cd(fullfile(rootdir,study,'results'));
end
fwhm=cell2table(fwhm,'VariableNames',varnames);
writetable(fwhm,['fwhm' outtag '.csv']);
disp('Done.');
end % end function