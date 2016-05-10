cd /younglab/studies/XPECT/behavioural
all_dir = dir('YOU_XPECT_*outcome*'); % this will have to be changed to reflect whatever the subset of behavioral files is actually needed
for i=1:length(all_dir)
    all_dir = dir('YOU_XPECT_*outcome*'); % this will have to be changed to reflect whatever the subset of behavioral files is actually needed
    load(all_dir(i).name);
    
%     %correct for previous mistake labeling
%     con_info(5).name = 'all accidental vs all intentional';
%     con_info(6).name = 'all intentional vs all accidental';
%     
%     %create new contrasts 
%     con_info(30).name = 'intentional psych harm vs intentional phys harm';
%     con_info(30).vals = [0 0 0 0 0 -1 1 0 0 0];
%     con_info(31).name = 'intentional phys harm vs intentional psych harm';
%     con_info(31).vals = [0 0 0 0 0 1 -1 0 0 0];
%     con_info(32).name = 'intentional psych harm vs accidental psych harm';
%     con_info(32).vals = [0 -1 0 0 0 0 1 0 0 0];
%     con_info(33).name = 'accidental psych harm vs intentional psych harm';
%     con_info(33).vals = [0 1 0 0 0 0 -1 0 0 0];
%     con_info(34).name = 'intentional phys harm vs accidental phys harm';
%     con_info(34).vals = [-1 0 0 0 0 1 0 0 0 0];
%     con_info(35).name = 'accidental phys harm vs intentional phys harm';
%     con_info(35).vals = [1 0 0 0 0 -1 0 0 0 0];
%     con_info(36).name = 'accidental psych harm vs accidental phys harm';
%     con_info(36).vals = [-1 1 0 0 0 0 0 0 0 0];
%     con_info(37).name = 'accidental phys harm vs accidental psych harm';
%     con_info(37).vals = [1 -1 0 0 0 0 0 0 0 0];
%     con_info(38).name = 'incest vs psych harm';
%     con_info(38).vals = [0 -1 1 0 0 0 -1 1 0 0];
%     
%     con_info = con_info(1:38);

    %create new contrasts 
    con_info(7).name = 'UN vs EN';
    con_info(7).vals = [-1 0 0 1 0 0];
    con_info(8).name = 'UB vs EB';
    con_info(8).vals = [0 -1 0 0 1 0];
    con_info(9).name = 'UM vs EM';
    con_info(9).vals = [0 0 -1 0 0 1];
    
    con_info(10).name = 'EN vs UN';
    con_info(10).vals = [1 0 0 -1 0 0];
    con_info(11).name = 'EB v UB';
    con_info(11).vals = [0 1 0 0 -1 0];
    con_info(12).name = 'EM v UM';
    con_info(12).vals = [0 0 1 0 0 -1];
    
    con_info(13).name = 'EN v EB';
    con_info(13).vals = [1 -1 0 0 0 0];
    con_info(14).name = 'EN v EM';
    con_info(14).vals = [1 0 -1 0 0 0];
    con_info(15).name = 'EB v EN';
    con_info(15).vals = [-1 1 0 0 0 0];
    con_info(16).name = 'EB v EM';
    con_info(16).vals = [0 1 -1 0 0 0];
    con_info(17).name = 'EM v EN';
    con_info(17).vals = [-1 0 1 0 0 0];
    con_info(18).name = 'EM v EB';
    con_info(18).vals = [0 -1 1 0 0 0];
    
    con_info(19).name = 'UN v UB';
    con_info(19).vals = [0 0 0 1 -1 0];
    con_info(20).name = 'UN v UM';
    con_info(20).vals = [0 0 0 1 0 -1];
    con_info(21).name = 'UB v UN';
    con_info(21).vals = [0 0 0 -1 1 0 ];
    con_info(22).name = 'UB v UM';
    con_info(22).vals = [0 0 0 0 1 -1 ];
    con_info(23).name = 'UM v UN';
    con_info(23).vals = [0 0 0 -1 0 1 ];
    con_info(24).name = 'UM v UB';
    con_info(24).vals = [0 0 0 0 -1 1 ];
    
    con_info = con_info(1:24);
    

    cd /younglab/studies/XPECT/behavioural;
    save(all_dir(i).name,'-append','con_info');
    
    
end