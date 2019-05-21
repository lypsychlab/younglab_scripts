% make contrasts:

study='VERBS';
tname='DIS_verbs';
subj_nums=[5:20 22:24 27:47];
rootdir='/home/younglw';
subj_tag='SAX_DIS';
resdir='DIS_verbs_results_concat_normed';

younglab_contrast_pleiades(rootdir,study,subj_tag,subj_nums,resdir,tname);
