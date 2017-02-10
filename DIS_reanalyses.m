% DIS_reanalyses
load(fullfile('/home/younglw/lab/server/englewood/mnt/englewood/data','PSYCH-PHYS','RSA_parameters.mat'));

% HARM
% DIS_combine_images({'physVpsyc_60_subdom_60_Zscore' 'phys_60_subdom_60_Zscore' 'phys_60_subdom_60_Zscore'},'harm_subdom_60_Zscore');
% PURITY
% DIS_combine_images({'incVpath_60_subdom_60_Zscore' 'inc_60_subdom_60_Zscore' 'path_60_subdom_60_Zscore'},'purity_subdom_60_Zscore');

% Making 1-sample T-images
% run_all_jobs({'harm_subdom_60_Zscore'},0);
% run_all_jobs({'purity_subdom_60_Zscore'},0);


%%% 60space RSA w/ Harm-Purity regressor %%%
% RSA
% DIS_rerun(0,'subdom_60_2',3,1,0);

% DIS_combine_images({'physVpsyc_60_subdom_60_2_Zscore' 'phys_60_subdom_60_2_Zscore' 'phys_60_subdom_60_2_Zscore'},'harm_subdom_60_2_Zscore');
% % PURITY
% DIS_combine_images({'incVpath_60_subdom_60_2_Zscore' 'inc_60_subdom_60_2_Zscore' 'path_60_subdom_60_2_Zscore'},'purity_subdom_60_2_Zscore');

% % Making 1-sample T-images
% run_all_jobs({'harm_subdom_60_2_Zscore'},0);
% run_all_jobs({'purity_subdom_60_2_Zscore'},0);

% % Getting FWHM to use with 3dClustSim
% getFWHM({'incVpath_60_subdom_60_2_Zscore' 'inc_60_subdom_60_2_Zscore' 'path_60_subdom_60_2_Zscore' 'physVpsyc_60_subdom_60_2_Zscore' 'phys_60_subdom_60_2_Zscore' 'psyc_60_subdom_60_2_Zscore' 'harm_subdom_60_2_Zscore' 'purity_subdom_60_2_Zscore'},'_subdom_60_2_Zscore');

% % Using FWHM values in 3dClustSim
% DIS_3dclustsim.sh

% Within-ROI RSA: all feature variables
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'acc_wrong' 'act' 'disgweight' 'env' 'hother_scale' 'hself_scale' 'int_wrong' 'mind' 'person_attr' 'rationality' 'sit_attr' 'weird'},...
%       'purity_LIFG_2', '_allfeat_LIFG');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'acc_wrong' 'act' 'disgweight' 'env' 'hother_scale' 'hself_scale' 'int_wrong' 'mind' 'person_attr' 'rationality' 'sit_attr' 'weird'},...
%       'harm_PC_2', '_allfeat_PC');

% Within-ROI RSA: Model matrices alone (for comparison in T-tests)
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath'}, 'harm_PC_2', '_cat_PC');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath'}, 'purity_LIFG_2', '_cat_LIFG');

% Load corrs for above
load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_allfeat_PC',sub_nums);
load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
	'PSYCH-PHYS','DIS_results_itemwise_normed','purity_LIFG_2_allfeat_LIFG',sub_nums);
load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_cat_PC',sub_nums);
load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
	'PSYCH-PHYS','DIS_results_itemwise_normed','purity_LIFG_2_cat_LIFG',sub_nums);

% Within-ROI RSA: Model matrices + Feature-variable matrices
% One of these for each feature variable included in the above step
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'acc_wrong'}, '_acc_wrong_LIFG');

% % Load corrs
% % One of these for each feature variable run in above step
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','name_for_regressinfo',0);

% % Make permuted matrices and run permuted-matrix RSA, within-ROI
% % One of these for each feature variable run in above step
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	[3:47],'nameoffeaturematrix',100,'purity_LIFG_2','categoricaltag')

% % T-tests
% % One of these for each feature variable run in above step
% permute_ttests('purity_LIFG_2','categoricaltag','continuoustag','permutedtag');

