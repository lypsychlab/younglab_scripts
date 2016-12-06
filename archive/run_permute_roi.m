% loc='/home/younglw/server/englewood/mnt/englewood/data';
% study='PSYCH-PHYS';
% subnums=3:47;
% bmatrix='behav_matrix_disgweight.mat';
% iter=100
% roi = 'purity_LIFG';
% findtag='purity_LIFG_cat1';

% permute_test_roi(loc,study,subnums,bmatrix,iter,roi,findtag);

loc='/home/younglw/server/englewood/mnt/englewood/data';
study='PSYCH-PHYS';
subnums=3:47;
bmatrix='behav_matrix_hother_scale.mat';
iter=100
roi = 'harm_PC';
findtag='harm_PC_cat2';

permute_test_roi(loc,study,subnums,bmatrix,iter,roi,findtag);