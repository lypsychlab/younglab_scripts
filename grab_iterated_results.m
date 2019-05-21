function grab_iterated_results(rootdir,study,subj_tag,sub_nums,resdir,roiname,intag)
	in_name = [roiname '_' intag];
	ALL=struct();
	for s=sub_nums
		f=load(fullfile(rootdir,study,sprintf([subj_tag '_%02d'],s),'results',resdir,['regressinfo_' in_name '.mat']));
		disp(['Subject ' num2str(s)]);
		for i = 2:length(f.iter_struct)
			if f.iter_struct(i).corrs ~= f.iter_struct(1).corrs
				disp(['No match: row ' num2str(i)]);
			end
		end


		% num = length(ALL)+1;
		% ALL(num).corrs = meancorrs;
		% ALL(num).bint = meanbint;
		% ALL(num).Rval = meanRval;
		% ALL(num).Rint = meanRint;
		% ALL(num).Stats = meanStats;
		clear f;
	end

	% out_name = ['all_regressinfo_' in_name '.mat'];
	% save(fullfile(rootdir,study,'results',out_name),'ALL')
end