% try_make_behav:

subj_nums=[3:20 22:24 27:35 36:42 44:47]; 
tagnames={'HvP_H_48', 'HvP_P_48','IntVAcc_Int_48','IntVAcc_Acc_48','Int_H','Int_P','Acc_H','Acc_P'};
groupings={[1 2 6 7], [3 4 8 9],[6 7 8 9],[1 2 3 4],[6 7],[8 9],[1 2],[3 4]};
for j=1:length(groupings)
	
	DIS_itemwise_make_behav_2group_pleiades(subj_nums,groupings{j},tagnames{j});
end
