% run_searchlight_euclid

rootdir='/home/younglw/lab/server/englewood/mnt/englewood/data/';
study='PSYCH-PHYS';
subj_tag='SAX_DIS';
resdir='DIS_results_itemwise_normed';
cond_in=[1:48];
sph=3;
B_in={'harm' 'purity'}
outtag='domainEuc';

for sub=22:47
try
searchlight_base_euclid(rootdir,study,subj_tag,resdir,sub,cond_in,sph,B_in,outtag);
catch
	continue
end
end