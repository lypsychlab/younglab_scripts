<<<<<<< HEAD
function ieh_recode_itemwise(subj_nums)

study='IEHFMRI';
% subj_nums=[4 6:8 11:14 16:22 24 25]; % all subjects leaving out 5 which has to be remodeled
=======
study='IEHFMRI';
subj_nums=[4 6:8 11:14 16:22 24 25]; % all subjects leaving out 5 which has to be remodeled
>>>>>>> 4ea36e0abf8da612bbc2f8f0c2b7dc72c0a45376
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
end


<<<<<<< HEAD
for thissub=1:length(subjs)
	betanames={};
	cd(fullfile('/younglab/studies',study,'duration60secs_behavioral'));

	for thisrun=1:8
		% load the behavioral file for that run
		fname=[subjs{thissub} '.ieh.' num2str(thisrun) '.mat'];
		f=load(fname);
		% get the condition info
		names=cell(15,1);
		for thisitem=1:15
			betanames{end+1}=[f.spm_inputs_itemwise(thisitem).name '.nii'];
		end
	end

	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
	betadir=dir('beta_*.nii');
	for thisbeta=1:120
		movefile(betadir(thisbeta).name,['beta_item_' sprintf('%03d',thisbeta) '_' betanames{thisbeta}]);
	end

end
end %end function

% condnames={'estim' 'imagn' 'journ' 'memry'};
% rootdir='/younglab/studies';
% resdir='ieh_results_itemwise_normed';
% subjIDs=subjs;
% roiname='Hipp_R'

% for thissub=1:length(subjs)
% 	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
% 	betadir=dir('beta_item*.nii');
% 	for thisbeta=1:length(betadir)
% 				item_tag=betadir(thisbeta).name(15:16);
% 				if strcmp(item_tag(2),'_')
% 					item_tag=sprintf('%02d',str2num(item_tag(1)));
% 					newname=[betadir(thisbeta).name(1:14) item_tag betadir(thisbeta).name(16:end)];
% 					movefile(betadir(thisbeta).name,newname);
% 				end
% 	end
% end
=======
% for thissub=1:length(subjs)
% 	betanames={};
% 	cd(fullfile('/younglab/studies',study,'duration60secs_behavioral'));

% 	for thisrun=1:8
% 		fname=[subjs{thissub} '.ieh.' num2str(thisrun) '.mat'];
% 		f=load(fname);
% 		names=cell(length(f.spm_inputs_itemwise),1);
% 		for thisitem=1:length(f.spm_inputs_itemwise)
% 			betanames{end+1}=[f.spm_inputs_itemwise(thisitem).name '.nii'];
% 		end
% 	end

% 	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
% 	betadir=dir('beta_*.nii');
% 	for thisbeta=1:length(betanames)
% 		movefile(betadir(thisbeta).name,['beta_item_' num2str(thisbeta) '_' betanames{thisbeta}]);
% 	end

% end
condnames={'estim' 'imagn' 'journ' 'memry'};
rootdir='/younglab/studies';
resdir='ieh_results_itemwise_normed';
subjIDs=subjs;
roiname='Hipp_R'

for thissub=1:length(subjs)
	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
	betadir=dir('beta_item*.nii');
	for thisbeta=1:length(betadir)
				item_tag=betadir(thisbeta).name(15:16);
				if strcmp(item_tag(2),'_')
					item_tag=sprintf('%02d',str2num(item_tag(1)));
					newname=[betadir(thisbeta).name(1:14) item_tag betadir(thisbeta).name(16:end)];
					movefile(betadir(thisbeta).name,newname);
				end
	end
end
>>>>>>> 4ea36e0abf8da612bbc2f8f0c2b7dc72c0a45376