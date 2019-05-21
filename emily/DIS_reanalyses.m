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
% getFWHM({'harmVpurity_60_subdom_60_2_Zscore' 'neut_60_subdom_60_2_Zscore'},'_subdom_60_2_Zscore');

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
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_allfeat_PC',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','purity_LIFG_2_allfeat_LIFG',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_cat_PC',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','purity_LIFG_2_cat_LIFG',sub_nums);

% permute_ttests('purity_LIFG_2','categoricaltag','continuoustag','permutedtag');

% Within-ROI RSA: Model matrices + Feature-variable matrices
% One of these for each feature variable included in the above step
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'disgweight'}, 'purity_LIFG_2','_disg_LIFG');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'rationality'}, 'purity_LIFG_2','_rat_LIFG');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'disgweight'}, 'harm_PC_2','_disg_PC');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'env'}, 'harm_PC_2','_env_PC');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'hother_scale'}, 'harm_PC_2','_hother_PC');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'mind'}, 'harm_PC_2','_mind_PC');
% rsa_roi('/home/younglw/lab/server/englewood/mnt/englewood/data',...
%       'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
%       {'phys' 'psyc' 'physVpsyc' 'inc' 'path' 'incVpath' 'person_attr'}, 'harm_PC_2','_person_attr_PC');

% % Load information from the within-ROI RSA above
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','purity_LIFG_2_disg_LIFG',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','purity_LIFG_2_rat_LIFG',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_disg_PC',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_env_PC',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_hother_PC',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_mind_PC',sub_nums);
% load_corrs('/home/younglw/lab/server/englewood/mnt/englewood/data/',...
% 	'PSYCH-PHYS','DIS_results_itemwise_normed','harm_PC_2_person_attr_PC',sub_nums);

% Download the all_regressinfo_*.mat files produced above

% % Make permuted matrices and run permuted-matrix RSA, within-ROI
% % One of these for each feature variable run in above step
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	sub_nums,'disgweight',100,'purity_LIFG_2','purity_LIFG_2_cat_LIFG',1);
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	sub_nums,'rationality',100,'purity_LIFG_2','purity_LIFG_2_cat_LIFG',1);
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	sub_nums,'disgweight',100,'harm_PC_2','harm_PC_2_cat_PC',70);
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	sub_nums,'env',100,'harm_PC_2','harm_PC_2_cat_PC',63);
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
	% sub_nums,'hother_scale',100,'harm_PC_2','harm_PC_2_cat_PC',1);
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	sub_nums,'mind',100,'harm_PC_2','harm_PC_2_cat_PC',94);
% permute_test_roi('/home/younglw/lab/server/englewood/mnt/englewood/data/','PSYCH-PHYS','DIS_results_itemwise_normed',...
% 	sub_nums,'person_attr',100,'harm_PC_2','harm_PC_2_cat_PC',1);

% % Download permute_test_roi*.mat files from above step

% % % T-tests
% % % One of these for each feature variable run in above step
% permute_ttests('purity_LIFG_2','cat_LIFG','disg_LIFG','disgweight');
% permute_ttests('purity_LIFG_2','cat_LIFG','rat_LIFG','rationality');
% permute_ttests('harm_PC_2','cat_PC','disg_PC','disgweight');
% permute_ttests('harm_PC_2','cat_PC','env_PC','env');
% permute_ttests('harm_PC_2','cat_PC','hother_PC','hother_scale');
% permute_ttests('harm_PC_2','cat_PC','mind_PC','mind');
% permute_ttests('harm_PC_2','cat_PC','person_attr_PC','person_attr');

% ASD-NT T-tests: getting images

% DIS_2samptest_job({'neut_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'harmVpurity_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'harm_subdom_60_2_Zscore'});
DIS_2samptest_job({'purity_subdom_60_2_Zscore'});
DIS_2samptest_job({'phys_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'psyc_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'physVpsyc_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'inc_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'path_60_subdom_60_2_Zscore'});
DIS_2samptest_job({'incVpath_60_subdom_60_2_Zscore'});



