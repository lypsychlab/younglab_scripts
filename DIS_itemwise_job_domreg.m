%-----------------------------------------------------------------------
% Job saved on 08-Dec-2015 15:06:09 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6470)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
rootdir='/mnt/englewood/data';study='PSYCH-PHYS';
cd(fullfile(rootdir,study));
tagnames={'domain_domharmintent' 'hother_domharmintent' 'IntVAcc_Int_48_domharmintent' 'IntVAcc_Acc_48_domharmintent'};
for t=1:length(tagnames)
matlabbatch{1}.spm.stats.factorial_design.dir = {['/mnt/englewood/data/PSYCH-PHYS/results/' tagnames{t} '/']};
% sub_nums=[3:20 22:24 27:35 38:42 44:47];
% subjIDs=cell(length(sub_nums),1);
% for sub=1:length(sub_nums)
%     subjIDs{sub}=char(sprintf(['SAX_DIS_' '%02d'],sub_nums(sub)));
% end 
% repmat(['/mnt/englewood/data/PSYCH-PHYS/' char(subjIDs) '/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']],39,1)
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_03/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_04/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_05/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_06/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_07/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_08/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_09/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_10/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_11/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_12/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_13/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_14/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_18/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_15/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_16/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_17/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_19/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_20/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_22/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_23/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_24/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_27/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_28/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_29/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_30/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_31/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_32/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_33/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_34/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_35/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_38/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_39/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_40/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_41/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_42/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_44/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_45/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_46/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          ['/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_47/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img,1']
                                                          };
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
output_list=spm_jobman('run',matlabbatch);
end