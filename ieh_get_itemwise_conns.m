study = 'IEHFMRI';
rootdir='/younglab/studies';
conndir='/conn/conn_IEHFMRI_ROI_allrois_128Hz/results/firstlevel/ANALYSIS_01';
subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
end
all_items=zeros(18,120);
cd(fullfile(rootdir,study,'duration60secs_behavioral'));
%load up all the condition codings
for thissub=1:18
	for thisrun=1:8
		f=load([subjs{thissub} '.ieh.' num2str(thisrun) '.mat']);
		for thisitem=1:15
			condcode=str2num(f.spm_inputs_itemwise(thisitem).name(end));
			switch condcode
				case 1
					recode=2; %estimate
				case 2
					recode=4; %imagine
				case 3
					recode=1; %journal
				case 4
					recode=3; %memory
				otherwise
					recode=condcode; %keep difficulty and story as 5 and 6
			end
			new_ind=thisitem+((thisrun-1)*15);
			all_items(thissub,new_ind)=recode;
		end
		clear f;
	end
end

cd(fullfile(rootdir,study,conndir));
all_conns=[];
for thissub=1:18
	for thiscond=1:120
		connfile=load(['resultsROI_Subject' sprintf('%03d',thissub) '_Condition' sprintf('%03d',thiscond) '.mat']);
		item_row=[];
		colnames={};
		for i=1:length(connfile.names)
			for j=1:length(connfile.names2)
				item_row = [item_row connfile.Z(i,j)]; 
				colnames{end+1}=[connfile.names{i} '_' connfile.names2{j}];
			end
		end
		all_conns=[all_conns; item_row];
		clear connfile;
	end
end
condcodes=reshape(all_items',[18*120,1]);%stretch it into a vector the same length as all_conns
subID=repmat([1:18],120,1);subID=reshape(subID,[18*120,1]);
save(fullfile(rootdir,study,'results','itemwise_conns_128Hz.mat'),'all_conns','condcodes','subID','colnames');




