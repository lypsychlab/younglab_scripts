%DIS_conn_loadbehavioral
%EXPER

load('/mnt/englewood/data/conn/DIS_ROI_Analysis_exper_wraf.mat');
cond_info=BATCH.Setup.conditions;
clear an BATCH firstlevel study;

%SET UP BASIC PARAMETER INFO
study='DIS_MVPA';
fname='DIS_ROI_Analysis_exper_wraf';
subj_nums=[3:15 19 22:24 29 31 34];
weirdsubs=[12 17:19];
subjs={};sessions={};
for s=subj_nums
    subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
end

cond_info.RT=cell(10,length(subjs),6);
cond_info.keys=cell(10,length(subjs),6);
cond_info.items=cell(10,length(subjs),6);

prev_dir=pwd;
cd(['/younglab/studies/' study '/behavioural/']);

for sub=1:length(subjs)
    if ~ismember(sub,weirdsubs)
        for DISnum=1:6 
            matname=load([subjs{sub} '.DIS.' num2str(DISnum) '.mat']);
            for ind=1:10
                design_index=matname.design_run(ind);
                cond_info.RT{design_index}{sub}{DISnum}=matname.RT(ind);
                cond_info.keys{design_index}{sub}{DISnum}=matname.key(ind);
                cond_info.items{design_index}{sub}{DISnum}=matname.items_run(ind);         
            end

            clear matname;
        end
    else
        
        if sub==12
            for d=1:10
                cond_info.RT{d}{sub}{1}=[0];
                cond_info.keys{d}{sub}{1}=[0];
                cond_info.items{d}{sub}{1}=[0]; 
            end
        end
        if exist([subjs{sub} '.DIS_behav.mat'])>0
            matname=load([subjs{sub} '.DIS_behav.mat']);
            for d=1:10
                cond_info.RT{d}{sub}{1}=[];
                cond_info.keys{d}{sub}{1}=[];
                cond_info.items{d}{sub}{1}=[]; 
            end
            for ind=1:60
                design_index=matname.design(ind);
                cond_info.RT{design_index}{sub}{1}=[cond_info.RT{design_index}{sub}{1} matname.RT(ind)];
                cond_info.keys{design_index}{sub}{1}=[cond_info.keys{design_index}{sub}{1} matname.key(ind)];
                cond_info.items{design_index}{sub}{1}=[cond_info.items{design_index}{sub}{1} matname.items(ind)];         
            end
        end
        clear matname;
    end
end
cd(prev_dir);

behav=cond_info;clear cond_info;
save('/mnt/englewood/data/conn/DIS_exper_data.mat','behav','-append');

%after adding the ROI data (DIS_conn_correlaterest script)
% load('/mnt/englewood/data/conn/DIS_exper_data.mat');

for cond=1:10
    for sub=1:20
        if ~ismember(sub,weirdsubs)
            for sess=1:6
                behav.RTmean{cond}{sub}(sess)=behav.RT{cond}{sub}{sess};
                behav.RTmean{cond}{sub}=mean(behav.RTmean{cond}{sub});
                behav.keysmean{cond}{sub}(sess)=behav.keys{cond}{sub}{sess};
                behav.keysmean{cond}{sub}=mean(behav.keysmean{cond}{sub});
            end
        else
            behav.RTmean{cond}{sub}=mean(behav.RT{cond}{sub}{1});
        end
    end
end


% %TOM
% load('/mnt/englewood/data/conn/DIS_ROI_Analysis_tom_wraf.mat');
% cond_info=BATCH.Setup.conditions;
% clear an BATCH firstlevel study;
% 
% tic;
% study='DIS_MVPA';
% subj_nums=[3:15 19 22:24 29 31 34];
% subjs={};sessions={};
% for s=subj_nums
%     subjs{end+1}=['SAX_DIS_' sprintf('%02d',s)];
%     if ismember(s,[5 9 16 19])
%         sessions{end+1}=[6 8 16 18];
%     elseif ismember(s,[7])
%         sessions{end+1}=[4 6 18 20];
%     elseif ismember(s,[14 24])
%         sessions{end+1}=[8 10 18 20];
%     elseif ismember(s,[17 32])
%         sessions{end+1}=[4 6 16 18];
%     else
%         sessions{end+1}=[4 6 14 16];
%     end
% end
% 
% an={'roi'};
% 
% prev_dir=pwd;
% 
% for sub=1:length(subjs)
%     for sessnum=1:4 
%         matname=dir([subjs{sub} '.*f*.' num2str(sessnum) '.mat']);
%         matname=matname.name;
%         load(matname);
%         for cond=1:2
%             
%         end
%     end
% end
% cd(prev_dir);