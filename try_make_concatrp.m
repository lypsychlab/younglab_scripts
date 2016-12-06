boldirs=[8 10 12 18 20 22];subj='SAX_DIS_03';em={};nms={};
for b=1:length(boldirs)
	cd(fullfile('/home/younglw/VERBS/',subj,'bold',sprintf('%03d',boldirs(b))));
	d=dir('rp_*txt');
	if length(d)==1
		em{b} = load(d(1).name);
		nms{b}=d(1).name;
	end
end


M=[];
for b=1:length(em)
	M=[M; em{b}];
end
M
cd(fullfile('/home/younglw/VERBS/',subj,'bold',sprintf('%03d',boldirs(1))));
dlmwrite(fullfile(pwd,['concat_' nms{1}]),M,' ');

