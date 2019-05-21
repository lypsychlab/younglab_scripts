load(fullfile('/home/younglw/lab/server/englewood/mnt/englewood/data','PSYCH-PHYS','RSA_parameters.mat'));
B_in = {'acc_wrong' 'act' 'disgweight' 'env' 'hother_scale' 'hself_scale' 'int_wrong' 'mind' 'person_attr' 'rationality' 'sit_attr' 'weird'};
B=[];
for b=1:length(B_in)
	load(fullfile(rootdir, study, 'behavioural_all',['behav_matrix_' B_in{b} '.mat']));
    disp(fullfile(rootdir, study, 'behavioural_all',['behav_matrix_' B_in{b} '.mat']));
    behav_matrix=sim2tril(behav_matrix);
	B=[B behav_matrix];
	clear behav_matrix;
end
B_cov = cov(B);
B_corr = corrcoef(B);
save(fullfile(rootdir,study,'feat_ortho_covariance.mat'),'B_corr','-append');