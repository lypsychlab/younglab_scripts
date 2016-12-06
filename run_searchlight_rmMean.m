% run_searchlight_rmMean

rootdir='/home/younglw/lab/server/englewood/mnt/englewood/data/';
study='PSYCH-PHYS';
subj_tag='SAX_DIS';
resdir='DIS_results_itemwise_normed';
% cond_in=[1:48];
cond_in=[1:60];
sph=3;

% B_in={'harm' 'purity'}
% B_in={'psyc' 'phys' 'physVpsyc' 'inc' 'path' 'incVpath'};
B_in={'harm_60' 'purity_60' 'harmVpurity_60'};

% outtag='_domainRmMean';
% outtag='_fourCondsRmMean';
outtag='_sixtyRmMean';

for sub=3:47
try
searchlight_base_rmMean(rootdir,study,subj_tag,resdir,sub,cond_in,sph,B_in,outtag);
catch
	continue
end
end

% estimate the SPM
for tg = 1:length(B_in)
	B_in{tg}=[B_in{tg} outtag];
end

try
	searchlight_onesamp(B_in);
catch
	disp('Unable to run searchlight_onesamp! Quitting.');
end

% generate T images
try
	estimate_spm_pleiades(rootdir,study,B_in)
catch
	disp('Unable to run estimate_spm_pleiades! Quitting.');
end