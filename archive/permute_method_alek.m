
num_iter=1;
tgs={'harm' 'purity'};
rootdir='/home/younglw/server/englewood/mnt/englewood/data';
study='PSYCH-PHYS';
conditions=[1:48];

load(fullfile(rootdir, study, 'behavioural','sub_nums'));

for t=1:length(tgs)

	for i=1:num_iter

		load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' tgs{t} '.mat']));
        shuffle=randperm(length(conditions));
        behav_matrix=tril(behav_matrix,-1)+behav_matrix';
        behav_matrix=behav_matrix(shuffle,shuffle);
        behav_matrix=tril(behav_matrix,0);
        save(fullfile(rootdir, study, 'behavioural',['behav_matrix_' tgs{t} 'K.mat']),'behav_matrix')
	    
	    inds=find([1:length(tgs)]~=t);
	    new_tgs={tgs{inds} [tgs{t} 'K']};

	    searchlight_all_regress_pleiades('/home/younglw/server/englewood/mnt/englewood/data',...
        'PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub_nums,[1:48],3,...
        new_tgs,['_' num2str(i)]);


	end

end