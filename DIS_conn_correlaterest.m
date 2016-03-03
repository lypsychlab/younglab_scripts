globaldir='/mnt/englewood/data/conn/';
exper='conn_DIS_ROI_Analysis_exper_wraf';
tom='conn_DIS_ROI_Analysis_tom_wraf';
respath='results/firstlevel/ANALYSIS_01';

%EXPER
for sub=1:20
    for cond=1:11
        cond_struct.results{cond}{sub}=load(fullfile(globaldir,exper,respath,['resultsROI_Subject' sprintf('%03d',sub) '_Condition' sprintf('%03d',cond) '.mat']));
    end
end
for sub=1:20
    for cond=1:11
        cond_struct.data_matrix{cond}{sub}=zeros(4,5);
        for roi=1:4
            for roi2=1:5
                cond_struct.data_matrix{cond}{sub}(roi,roi2)=cond_struct.results{cond}{sub}.Z(roi,roi2);
            end
        end
    end
end
%has form: data_matrix{condition}{roi}(subject,condition,connected roi)
D.names=cond_struct.results{1}{1}.names2;
D.data=cond_struct.data_matrix;

foo=cond_struct;
foo.D=D; clear D; D=foo; clear foo cond_struct;

save(fullfile('/mnt/englewood/data/conn/','DIS_exper_data.mat'),'D','-append');




% %TOM
% for sub=1:20
%     cond_struct.rest{sub}=load(fullfile(globaldir,exper,respath,['resultsROI_Subject' sprintf('%03d',sub) '_Condition011.mat']))
%     cond_struct.belief{sub}=load(fullfile(globaldir,tom,respath,['resultsROI_Subject' sprintf('%03d',sub) '_Condition001.mat']))
%     cond_struct.photo{sub}=load(fullfile(globaldir,tom,respath,['resultsROI_Subject' sprintf('%03d',sub) '_Condition002.mat']))
% end
% 
% 
% for roi=1:4
%     cond_struct.data_matrix{roi}=zeros(20,3,5);
%     for sub=1:20
%             for roi2=1:5
%                 cond_struct.data_matrix{roi}(sub,1,roi2)=cond_struct.rest{sub}.Z(roi,roi2);
%                 cond_struct.data_matrix{roi}(sub,2,roi2)=cond_struct.belief{sub}.Z(roi,roi2);
%                 cond_struct.data_matrix{roi}(sub,3,roi2)=cond_struct.photo{sub}.Z(roi,roi2);
%             end
%     end
% end
% 
% %has form: data_matrix{roi}(subject,condition,connected roi)
% D.names=cond_struct.belief{1}.names2;
% D.data=cond_struct.data_matrix;
% D.contrast_names=cell(2,4,5);
% 
% %has form: D.corr.[contrast name]{roi}{roi2}=correlation between roi and
% %roi2
% 
% for roi=1:4
%     for roi2=1:5
%         [corr1R,corr1P]=corrcoef(D.data{roi}(:,1,roi2),D.data{roi}(:,2,roi2));
%         [corr2R,corr2P]=corrcoef(D.data{roi}(:,1,roi2),D.data{roi}(:,3,roi2));
%         D.corr.rest_belief{roi}{roi2}.R=corr1R(2);
%         D.corr.rest_photo{roi}{roi2}.R=corr2R(2);
%         D.corr.rest_belief{roi}{roi2}.P=corr1P(2);
%         D.corr.rest_photo{roi}{roi2}.P=corr2P(2);
%         D.contrast_names{1}{roi}{roi2}=['REST-BELIEF:' D.names{roi} '_to_' D.names{roi2}];
%         D.contrast_names{2}{roi}{roi2}=['REST-PHOTO:' D.names{roi} '_to_' D.names{roi2}];
% 
%     end
% end
% 
% foo=cond_struct;
% foo.D=D; clear D; D=foo; clear foo cond_struct;
% 
% save(fullfile('/mnt/englewood/data/conn/','DIS_correlaterest.mat'),'D');
% 
% 
