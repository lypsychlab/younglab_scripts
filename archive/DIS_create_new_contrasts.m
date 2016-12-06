cd /younglab/studies/DIS/behavioural
all_dir = dir('SAX_DIS_*new_fbv*');
for i=1:length(all_dir)
    all_dir = dir('SAX_DIS_*new_fbv*');
    load(all_dir(i).name);
    
    con_info = con_info(1);
    
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
    
    

    cd /younglab/studies/DIS/behavioural;
    save(all_dir(i).name,'-append','con_info');
    
    
end