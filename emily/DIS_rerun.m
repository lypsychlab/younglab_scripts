	% 02/2017: rerun analyses

function DIS_rerun(load_flag,analysis_flag,starting_subject,function_flag,splitgroup)
% load_flag: 1 to load saved params, 0 to build from scratch
% analysis_flag: 'supra','dom','subdom','subdom_60'
% starting_subject: number of first subject to include
% function_flag: 1 to run searchlight, 2 to run Rmap, 0 to just run estimate_spm_pleiades
% splitgroup: 1 to also split T-images by ASD/NT, 0 to only do all subjects
% General parameters (run once)
	rootdir = '/home/younglw/lab/server/englewood/mnt/englewood/data';
	study = 'PSYCH-PHYS';
	if(load_flag)
		load(fullfile(rootdir,study,'RSA_parameters.mat'));
	else
		rootdir = '/home/younglw/lab/server/englewood/mnt/englewood/data';
		study = 'PSYCH-PHYS';
		subj_tag = 'SAX_DIS';
		resdir = 'DIS_results_itemwise_normed';
		cond_in = {[1:60],[1:48]};
		sph = 3;
		load(fullfile(rootdir,study,'behavioural_all','sub_nums.mat'));
		
		B_in = {};
		B_in{end+1} = {'harm_60' 'purity_60' 'harmVpurity_60' 'neut_60'};
		B_in{end+1} = {'harm' 'purity'};
		B_in{end+1} = {'phys' 'psyc' 'inc' 'path' 'physVpsyc' 'incVpath'};
		B_in{end+1} = {'phys_60' 'psyc_60' 'physVpsyc_60' 'inc_60' 'path_60' 'incVpath_60' 'neut_60'};
		B_in{end+1} = {'phys_60' 'psyc_60' 'physVpsyc_60' 'inc_60' 'path_60' 'incVpath_60' 'harmVpurity_60' 'neut_60'};

		outtags = {};
		outtags{end+1} = 'sixtydom_Zscore';
		outtags{end+1} = 'dom_Zscore';
		outtags{end+1} = 'subdom_Zscore'; 
		outtags{end+1} = 'subdom_60_Zscore';
		outtags{end+1} = 'subdom_60_2_Zscore';

		tagnames=cell(length(B_in));
		for(i=1:length(B_in))
			foo = {};
			for(j=1:length(B_in{i}))
				foo{end+1} = [B_in{i}{j} '_' outtags{i}];
			end
			tagnames{i} = foo;
			clear foo;
		end

		save(fullfile(rootdir,study,'RSA_parameters.mat'),'rootdir','study','subj_tag','sub_nums','resdir','cond_in','sph','B_in','outtags','tagnames');
	end
	ind = find(sub_nums==starting_subject);
	sub_nums=sub_nums(ind:end);


% Supradomain:
	switch analysis_flag
	case 'supra'
		if(function_flag) == 1
			searchlight_base(rootdir,study,subj_tag,resdir,sub_nums,cond_in{1},sph,B_in{1},outtags{1});
		end
		run_all_jobs(tagnames{1},splitgroup);
	case 'dom'
		if(function_flag) == 1
			searchlight_base(rootdir,study,subj_tag,resdir,sub_nums,cond_in{2},sph,B_in{2},outtags{2});
		end
		run_all_jobs(tagnames{2},splitgroup);
	case 'subdom' 
		if(function_flag)
			searchlight_base(rootdir,study,subj_tag,resdir,sub_nums,cond_in{2},sph,B_in{3},outtags{3});
		end
		run_all_jobs(tagnames{3},splitgroup);
	case 'subdom_60'
		if(function_flag)
			searchlight_base(rootdir,study,subj_tag,resdir,sub_nums,cond_in{1},sph,B_in{4},outtags{4});
		end
		run_all_jobs(tagnames{4},splitgroup);
	case 'subdom_2_60'
		if(function_flag) == 1
			searchlight_base(rootdir,study,subj_tag,resdir,sub_nums,cond_in{1},sph,B_in{5},outtags{5});
		end
		if(function_flag) == 2
			searchlight_Rmap(rootdir,study,subj_tag,resdir,sub_nums,cond_in{1},sph,B_in{5},outtags{5});
		end
		% run_all_jobs(tagnames{5},splitgroup);
	case 'subdom_3_60'
		if(function_flag) == 1
			searchlight_base(rootdir,study,subj_tag,resdir,sub_nums,cond_in{1},sph,B_in{6},outtags{6});
		end
		run_all_jobs(tagnames{6},splitgroup);
	otherwise
		disp('Invalid analysis flag! Exiting.');
		return;
	end

end %end function