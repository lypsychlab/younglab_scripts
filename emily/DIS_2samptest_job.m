function DIS_2samptest_job(tagnames)
rootdir='/home/younglw/lab/server/englewood/mnt/englewood/data';study='PSYCH-PHYS';
cd(fullfile(rootdir,study));
for t=1:length(tagnames)
	design_dir1 = ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/results/' tagnames{t} '_NT/'];
  design_dir2 = ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/results/' tagnames{t} '_ASD/'];
  mkdir(design_dir1);
  mkdir(design_dir2);
	% NT 
	scans1 = {
														                              ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_03/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_04/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_05/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_06/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_07/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_08/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_09/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_10/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_11/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_12/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_13/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_14/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_27/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_28/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_32/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_33/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_34/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_35/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_38/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_40/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_41/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_42/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_45/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_46/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_47/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          };
	% ASD                                                          
	scans2 = {
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_18/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_15/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_16/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_17/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_19/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_20/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_22/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_23/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_24/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_29/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_30/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_31/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_39/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                          ['/home/younglw/lab/server/englewood/mnt/englewood/data/PSYCH-PHYS/SAX_DIS_44/results/DIS_results_itemwise_normed/RSA_searchlight_regress_' tagnames{t} '.img']
                                                         };
for x = 1:length(scans1)
  [pathstr,fname,ext] = fileparts(scans1{x});
  copyfile(scans1{x},[design_dir1 '/' fname '_NT_' num2str(x) ext]);
  copyfile(fullfile(pathstr,[fname '.hdr']),[design_dir1 '/' fname '_NT_' num2str(x) '.hdr']);
end
for x = 1:length(scans2)
  [pathstr,fname,ext] = fileparts(scans2{x});
  copyfile(scans2{x},[design_dir2 '/' fname '_ASD_' num2str(x) ext]);
  copyfile(fullfile(pathstr,[fname '.hdr']),[design_dir2 '/' fname '_ASD_' num2str(x) '.hdr']);
end
end %end function