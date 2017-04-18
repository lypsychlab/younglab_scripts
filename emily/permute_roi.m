function permute_roi(ind)
	loc='/home/younglw/server/englewood/mnt/englewood/data';
	study='PSYCH-PHYS';
	subnums=3:47;
	iter=100;
	roi=cell(2,1);
	findtag{1}='harm_PC_cat2';
	findtag{3}='harm_PC_cat2';
	findtag{2}='purity_LIFG_cat1';
	findtag{4}='purity_LIFG_cat1';

	bmatrix{1}='behav_matrix_person_attr_raw.mat';
	bmatrix{3}='behav_matrix_env_raw.mat';
	bmatrix{2}='behav_matrix_disg_raw.mat';
	bmatrix{4}='behav_matrix_mind_raw.mat';

	roi{2}='harm_PC';
	roi{1}='purity_LIFG';

	resdir='DIS_results_itemwise_normed';

	roiind=mod(ind,2)+1;

	permute_test_roi(loc,study,resdir,subnums,bmatrix{ind},iter,roi{roiind},findtag{ind});


end %end function