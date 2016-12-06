cd /home/younglw/VERBS/behavioural

% newdir='/home/younglw/VERBS/behavioural';

filedir=dir('*DIS_verbs*.mat');

for f=1:length(filedir)
	% movefile(filedir(f).name,fullfile(newdir,filedir(f).name));
	load(filedir(f).name);
	% for s=1:length(spm_inputs)
	% 	spm_inputs(s).ons=spm_inputs(s).ons';
	% end
	% for c=1:length(con_info)
	% 	val=con_info(c).value;
	% 	con_info(c).vals=val;
	% end
	% rmfield('con_info','value');

	ips=166;
	save(filedir(f).name);
end