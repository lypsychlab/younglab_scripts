clear all;
<<<<<<< HEAD
% subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
subj_nums=[5];

=======
subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
subj_nums=[5];
>>>>>>> 4ea36e0abf8da612bbc2f8f0c2b7dc72c0a45376
subjs={};sessions={};
csv_data=csvread('/younglab/studies/IEHFMRI/subjs_sessions.csv',1,0);
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
    snum=find(csv_data(:,1)==subj_nums(s));
    
    sessions{end+1}=csv_data(snum,2:end-2);

end

nruns=8;
tname='ieh';

% function spm_inputs_itemwise_IEH(root_dir,study,subjs,runs,taskname)

% spm_inputs_itemwise_IEH('younglab','IEHFMRI',subjs,nruns,tname);

for s=1:length(subjs)
%     try
        younglab_model_spm8_itemwise_smooth_IEH('IEHFMRI',subjs{s},...
        'ieh',sessions{s});
%     catch
%     end
end
<<<<<<< HEAD
=======

%TEST CODE (uncomment to test on first subject)
s=1;
younglab_model_spm8_itemwise_smooth_IEH('IEHFMRI',subjs{s},...
        'ieh',sessions{s});
>>>>>>> 4ea36e0abf8da612bbc2f8f0c2b7dc72c0a45376
