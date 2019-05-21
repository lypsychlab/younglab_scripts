cd /home/younglw/VERBS/behavioural

% newdir='/home/younglw/VERBS/behavioural';

% filedir=dir('*DIS_verbs*.mat');
% filedir2=dir('*verbsCOR*')

subjs={};sessions={};
subj_nums=[3:47];
exclude=[21 25 26 36 37 43];

for s=subj_nums
	if ~ismember(s,[exclude])
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
	end
end
clear s;

for snum=1:length(subjs)
	for rnum=1:6
		disp([subjs{snum} ' ' num2str(rnum)]);
		% COR=load([subjs{snum} '_verbsCOR_' num2str(rnum) '.mat']);
		load([subjs{snum} '.DIS_verbs.' num2str(rnum) '.mat']);
		% design=COR.design;
		% for inp=1:length(COR.spm_inputs)
		% 	COR.spm_inputs(inp).dur=COR.spm_inputs(inp).dur';
		% end
		% spm_inputs=COR.spm_inputs;
		% con_info=COR.con_info;
		% clear COR;
		for inp=1:length(spm_inputs)
			spm_inputs(inp).name=spm_inputs(inp).name{1};
			% spm_inputs(inp).ons=spm_inputs(inp).ons';
			% spm_inputs(inp).dur=spm_inputs(inp).dur';
		end		
		save([subjs{snum} '.DIS_verbs.' num2str(rnum) '.mat'],'spm_inputs','-append');

		% load([subjs{snum} '.DIS_verbs.' num2str(rnum) '.mat']);
		% for inp=1:length(spm_inputs)
		% 	spm_inputs(inp).dur=spm_inputs(inp).dur';
		% end
		% save([subjs{snum} '.DIS_verbs.' num2str(rnum) '.mat']);
	end
end