
function make_4d(rootdir,study,tag,outtag,thresh,iter,fdr_flag)

% check to see if 4d file already exists:
cd(fullfile(rootdir,study,'results',[tag '_' outtag]));
if exist([tag '_' outtag '_4D.nii'])==0

  C={
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_03/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_04/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_05/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_06/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_07/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_08/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_09/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_10/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_11/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_12/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_13/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_14/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_18/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_15/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_16/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_17/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_19/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_20/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_22/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_23/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_24/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_27/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_28/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_29/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_30/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_31/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_32/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_33/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_34/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_35/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_38/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_39/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_40/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_41/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_42/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_44/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_45/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_46/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          ['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_47/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tag '_' outtag '.img,1']
                                                          };


  mkdir(fullfile(rootdir,study,'results',outtag));
  clear matlabbatch;
  matlabbatch{1}.spm.util.cat.vols = C;
  matlabbatch{1}.spm.util.cat.name = [tag '_' outtag '_4D.nii'];
  matlabbatch{1}.spm.util.cat.dtype = 0; %same as input files
  output_list=spm_jobman('run',matlabbatch);

  movefile(['/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_03/results/DIS_results_itemwise_normed/' tag '_' outtag '_4D.nii'],...
  	fullfile(rootdir,study,'results',[tag '_' outtag]));
end %end if file doesn't exist

%run this always
cd(fullfile(rootdir,study,'results',[tag '_' outtag]));

eval(sprintf('!randomise -i %s -o %s -1 -c %f -n %d -x --uncorrp',[tag '_' outtag '_4D.nii'],[tag '_' outtag],thresh,iter));
eval(sprintf('!gunzip %s.nii.gz -f',[tag '_' outtag '_tstat1']));
eval(sprintf('!gunzip %s.nii.gz -f',[tag '_' outtag '_clustere_p_tstat1']));
eval(sprintf('!gunzip %s.nii.gz -f',[tag '_' outtag '_clustere_corrp_tstat1']));
eval(sprintf('!gunzip %s.nii.gz -f',[tag '_' outtag '_vox_p_tstat1']));
eval(sprintf('!gunzip %s.nii.gz -f',[tag '_' outtag '_vox_corrp_tstat1']));

eval(sprintf('!rm -rf %s.nii.gz',[tag '_' outtag '_tstat1']));
eval(sprintf('!rm -rf %s.nii.gz',[tag '_' outtag '_clustere_p_tstat1']));
eval(sprintf('!rm -rf %s.nii.gz',[tag '_' outtag '_clustere_corrp_tstat1']));
eval(sprintf('!rm -rf %s.nii.gz',[tag '_' outtag '_vox_p_tstat1']));
eval(sprintf('!rm -rf %s.nii.gz',[tag '_' outtag '_vox_corrp_tstat1']));

if fdr_flag
eval(sprintf('!fdr -i %s --oneminusp -q %f --othresh=%s',[tag '_' outtag '_vox_p_tstat1'],thresh,[tag '_' outtag '_fdrcorrp']));
eval(sprintf('!gunzip %s.nii.gz -f',[tag '_' outtag '_fdrcorrp']));
eval(sprintf('!rm -rf %s.nii.gz',[tag '_' outtag '_fdrcorrp']));
end
end %end function