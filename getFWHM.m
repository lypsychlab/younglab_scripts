function getFWHM(tgs,outtag)

varnames={'Regressor' 'FWHMx' 'FWHMy' 'FWHMz'};
fwhm=cell(length(tgs),4);
for t=1:length(tgs)
	disp(['Grabbing FWHM for ' tgs{t} '...']);
	cd(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/results',tgs{t}));
	f=load('SPM.mat');
	fwhm{t,1}=tgs{t};
	fwhm{t,2}=f.SPM.xVol.FWHM(1);
	fwhm{t,3}=f.SPM.xVol.FWHM(2);
	fwhm{t,4}=f.SPM.xVol.FWHM(3);
	clear f;
end
cd(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/results'));
fwhm=cell2table(fwhm,'VariableNames',varnames);
writetable(fwhm,['fwhm' outtag '.csv']);
disp('Done.');
end