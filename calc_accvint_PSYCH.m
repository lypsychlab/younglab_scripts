% function calculate_behav_PSYCH(root_dir,study,sub_nums,task)
    clear all

    root_dir='/mnt/englewood/data';
    study='PSYCH-PHYS';
    sub_nums=[3:20 22:24 27:35 38:42 44:47];
% sub_nums=[3:47];
    task='DIS';
    
    cd(fullfile(root_dir,study,'behavioural'));
    all_sub_keys=zeros(length(sub_nums),7);
    
    for sub=1:length(sub_nums)
        try
        sub_name=sprintf('SAX_DIS_%02d',sub_nums(sub));
        all_key=[];
        clear f;
        for i=1:6
            f=load([sub_name '.' task '.' num2str(i) '.mat']);
            all_key=[all_key; f.key];
        end

        key_h_acc=[];
        key_h_int=[];
        key_p_acc=[];
        key_p_int=[];
        pur_acc=find(ismember(f.design,[3 4]));
        pur_int=find(ismember(f.design,[8 9]));
        harm_acc=find(ismember(f.design,[1 2]));
        harm_int=find(ismember(f.design,[6 7]));
  
        for j=1:length(harm_acc)
            key_h_acc=[key_h_acc;all_key(harm_acc(j))];
            key_h_int=[key_h_int;all_key(harm_int(j))];
        end
        
        for j=1:length(pur_acc)
            key_p_acc=[key_p_acc;all_key(pur_acc(j))];
            key_p_int=[key_p_int;all_key(pur_int(j))];
        end
        
        all_sub_keys(sub,1)=sub_nums(sub);
        all_sub_keys(sub,2)=nanmean(key_h_acc);
        all_sub_keys(sub,3)=nanmean(key_h_int);
        all_sub_keys(sub,5)=nanmean(key_p_acc);
        all_sub_keys(sub,6)=nanmean(key_p_int);
        
        catch
            disp(['Could not process subject ' num2str(sub)]);
            all_sub_keys(sub,1)=sub_nums(sub);
            
        end
    end % end subject loop


for i=1:39
    all_sub_keys(i,4)=all_sub_keys(i,3)-all_sub_keys(i,2);
    all_sub_keys(i,7)=all_sub_keys(i,6)-all_sub_keys(i,5);
end

condinfo={'ID' 'Harm_Acc' 'Harm_Int' 'Harm_Diff' 'Pur_Acc' 'Pur_Int' 'Pur_Diff'};
save('allkeys_39.mat','all_sub_keys','condinfo');




% end % end function