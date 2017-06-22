B_in = {'acc_wrong' 'act' 'disgweight' 'env' 'hother_scale' 'hself_scale' 'int_wrong' 'mind' 'person_attr' 'rationality' 'sit_attr' 'weird'};
rootdir = '/home/younglw/lab/server/englewood/mnt/englewood/data';
study = 'PSYCH-PHYS';
B = [];
for b=1:length(B_in)
	load(fullfile(rootdir, study, 'behavioural_all',['behav_matrix_' B_in{b} '.mat']));
    disp(fullfile(rootdir, study, 'behavioural_all',['behav_matrix_' B_in{b} '.mat']));
    behav_matrix=sim2tril(behav_matrix);
	B=[B behav_matrix];
	clear behav_matrix;
end
orthreg = orthogonalize_reg(B);
for b = 1:length(B_in)
	behav_matrix = B(:,b);
	save(fullfile(rootdir, study, 'behavioural_all',['behav_matrix_' B_in{b} '_ortho.mat']),'behav_matrix');
end