sub_nums=[3:47];
subjs={};

for i=1:length(sub_nums)
	subjs{i}=['SAX_DIS_' sprintf('%02d',sub_nums(i))];
end

rootdir='/home/younglw/lab/server/englewood/mnt/englewood/data';

runs={[4 6 14 16] [4 6 14 16] [6 8 16 18] [4 6 14 16] [4 6 18 20] ... %3
[4 6 14 16] [6 8 16 18] [4 6 14 16] [4 6 14 16] [4 6 14 16] ... %8
[4 6 14 16] [8 10 18 20] [4 6 14 16] [6 8 16 18] [4 6 16 18] ... %13
[4 6 14 16] [6 8 16 18] [4 6 14 16] [0 0 0 0] [4 6 14 16] ... %18
[4 6 14 16] [8 10 18 20] [4 6 14 16] [0 0 0 0] [4 6 14 16] ... %23
[4 6 14 16] [4 6 14 16] [4 6 14 16] [4 6 14 16] [4 6 16 18] ... %28
[4 6 14 16] [4 6 14 16] [4 6 14 16] [0 0] [12 14] ... %33
[10 12] [10 12] [10 12] [12 14] [10 12] ... %38
[12 14] [12 14] [10 12] [10 12] [10 12] ... %43
};

for j=1:length(subjs)
	try
		cd(fullfile(rootdir,'behavioural'));
		if exist([subjs{j} '.fb_sad.1.mat']) ~= 0
			loc_name='fb_sad';
		else if exist([subjs{j} '.new_fbv.1.mat']) ~= 0
			loc_name='new_fbv';
		else
			loc_name='tomloc';
		end

		younglab_model_spm12_pleiades_dis('PSYCH-PHYS',subjs{j},loc_name,runs{j},'clobber');
	catch
		disp(['Could not model' subjs{j}]);
		continue
	end
end