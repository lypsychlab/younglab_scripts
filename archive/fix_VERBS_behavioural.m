cd /home/younglw/VERBS/behavioural

% newdir='/home/younglw/VERBS/behavioural';

% filedir=dir('*DIS_verbs*.mat');
% old_dir=dir('*.DIS.*.mat');

subjs={};sessions={};
subj_nums=[22:24 27:35 38:42 44:47];
exclude=[21 25 26 36 37 43];

for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];

    if ismember(s,[5 9 16])
        sessions{end+1}=[10 12 14 20 22 24];
    elseif ismember(s,[7 14 24])
        sessions{end+1}=[12 14 16 22 24 26];
    elseif ismember(s,[37 44])
        sessions{end+1}=[6 8 10 16 18 20];
    elseif ismember(s,[38 39 40 42 45 46 47])
        sessions{end+1}=[4 6 8 14 16 18];
    else
        sessions{end+1}=[8 10 12 18 20 22];
    end
end
clear s;



sub=1;
% for s=1:length(subjs)
while sub < 48
	
	for sess=1:6
		disp(['Working on subject ' subjs{sub} ' session ' num2str(sess)])
		% try
			load([subjs{sub} '.DIS.' num2str(sess) '.mat']);
			clear spm_inputs con_info user_regressors design_run;
			D=design; %all design items run
			load(sprintf(['DIS_verbs_' '%02d' '_' num2str(sess) '.mat'],subj_nums(sub)));
		% 	% rmfield(con_info,'value');
			design_run=design; %just the ones for this session
			design=D; 
			clear D; 
			for inp=1:length(spm_inputs)
				spm_inputs(inp).name=spm_inputs(inp).name{1};
				spm_inputs(inp).ons=spm_inputs(inp).ons';
				spm_inputs(inp).dur=spm_inputs(inp).dur';
			end
			save([subjs{sub} '.DIS_verbs.' num2str(sess) '.mat']);
		% catch
		% 	disp(['Unable to fix behavioural for subject ' subjs{s}])
		% end
	end
	sub=sub+1;

end
% end

% for f=1:length(filedir)
% 	% movefile(filedir(f).name,fullfile(newdir,filedir(f).name));
% 	load(filedir(f).name);
% 	for s=1:length(spm_inputs)
% 		spm_inputs(s).ons=spm_inputs(s).ons';
% 		spm_inputs(s).dur=spm_inputs(s).dur';
% 	end
% 	% for c=1:length(con_info)
% 	% 	val=con_info(c).value;
% 	% 	con_info(c).vals=val;
% 	% end
% 	% rmfield('con_info','value');

% 	ips=166;
% 	save(filedir(f).name);
% end