rootdir = '/home/younglw/lab/STOR';
prefix = 'YOU_STOR_';
subjs = {};
for i=1:15
	subjs{end+1}=fullfile(rootdir,[prefix sprintf('%02d',i)]);
end

% roi_picker_laura(.001,10,9,1,'DMPFC','[0; 0; 0]',subjs,'results/tom_localizer_results_normed');
roi_picker_laura(.001,10,9,1,'VMPFC','[0; 0; 0]',subjs,'results/tom_localizer_results_normed');