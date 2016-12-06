clear all

study='IEHFMRI';
% fname='IEHFMRI_S2V_parahippL';
subj_nums=[4:8 11:14 16:22 24 25]; % all subjects
% subj_nums=[5 7 13 14 16:22] % subjects with all 4 TOM ROIs
% subj_nums=[4 5 7 8 11:14 16:22 24 25] % RTPJ + LTPJ
% subj_nums=[5 7 8 13 14 16:22]; % RTPJ + DMPFC
% subj_nums=[4 5 7 11:14 16:22 24 25]; % RTPJ + PC

% exclude_subs=[4 7 13 16 25];

csv_data=csvread('/younglab/studies/IEHFMRI/subjs_sessions.csv',1,0);
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['1' sprintf('%02d',subj_nums(s))];
    snum=find(csv_data(:,1)==subj_nums(s));
    sessions{end+1}=csv_data(snum,2:end-2);
%     if ismember(s,[5 9 16])
%         sessions{end+1}=[10 12 14 20 22 24];
%     elseif ismember(s,[7 14 24])
%         sessions{end+1}=[12 14 16 22 24 26];
%     elseif ismember(s,[37 44])
%         sessions{end+1}=[6 8 10 16 18 20];
%     elseif ismember(s,[38 39 40 42 45 46 47])
%         sessions{end+1}=[4 6 8 14 16 18];
%     else
%         sessions{end+1}=[8 10 12 18 20 22];
%     end
end
% Sample call (NEW: roi_batch('younglab','IEHFMRI',...
% 'YOU_IEHFMRI',{'104' '105'},'RTPJ','ieh_results_normed_Dur60','tom_localizer_results_normed','1', 60, 6, 0, '0:0');

roi_batch('younglab','IEHFMRI','YOU_IEHFMRI',subjs,'RTPJ','ieh_resultsNEW_autocon_normed',...
    'tom_localizer_results_normed','1',60,6,0,'0:10');