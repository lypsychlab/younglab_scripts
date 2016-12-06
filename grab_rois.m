subj_nums=26:47;
root_dir='/home/younglw/PSYCH-PHYS';
root_2='/home/younglw/';

subjs={};
for s=subj_nums
	subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
end

for sub=1:length(subjs)
	if exist(fullfile(root_dir,subjs{sub},'roi'))>0
		cd(fullfile(root_dir,subjs{sub},'roi'));
		if ~isempty(dir('ROI*'))
			items=dir('ROI*');
			for item=1:length(items)
				copyfile([pwd '/' items(item).name],[root_2 '/all_rois/' subjs{sub}]);
			end
		end
	end
end
