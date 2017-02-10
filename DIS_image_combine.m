% HARM
% DIS_combine_images({'physVpsyc_60_subdom_60_Zscore' 'phys_60_subdom_60_Zscore' 'phys_60_subdom_60_Zscore'},'harm_subdom_60_Zscore');
% PURITY
% DIS_combine_images({'incVpath_60_subdom_60_Zscore' 'inc_60_subdom_60_Zscore' 'path_60_subdom_60_Zscore'},'purity_subdom_60_Zscore');

run_all_jobs({'harm_subdom_60_Zscore'},0);
run_all_jobs({'purity_subdom_60_Zscore'},0);