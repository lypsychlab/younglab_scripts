% This script was last edited by Brendan Gaesser 2/2/2014

cd /younglab/studies/IEHFMRI/behavioural
all_dir = dir('YOU_IEHFMRI_*ieh*'); % this will have to be changed to reflect whatever the subset of behavioral files is actually needed
for i=1:length(all_dir)
    all_dir = dir('YOU_IEHFMRI_*ieh*'); % this will have to be changed to reflect whatever the subset of behavioral files is actually needed
    load(all_dir(i).name);
   
    
%     %correct for previous mistake labeling
%     con_info(5).name = 'all accidental vs all intentional';
%     con_info(6).name = 'all intentional vs all accidental';
%     
%     previous contrasts
%       con_info(1) = imagine v identify 
%       con_info(2) = imagine v estimate 
%       con_info(3) = fixation v identify (i.e., journal)
%       con_info(4) = memory v identify 

    %create new contrasts 
    con_info(5).name = 'memory v estimate';
    con_info(5).vals = [-1 0 0 1 0 0];
    con_info(6).name = 'imagine v memory';
    con_info(6).vals = [0 1 0 -1 0 0];
    con_info(7).name = 'memory v imagine';
    con_info(7).vals = [0 -1 0 1 0 0];
    con_info(8).name = 'imag v journ and estim';
    con_info(8).vals = [-.5 1 -.5 0 0 0];
    con_info(9).name = 'mem v journ and estim';
    con_info(9).vals = [-.5 0 -.5 1 0 0];
   
    con_info(10).name = 'imag and mem v journ';
    con_info(10).vals = [0 .5 -1 .5 0 0];
    con_info(11).name = 'imag and mem v estim';
    con_info(11).vals = [-1 .5 0 .5 0 0];
    con_info(12).name = 'imag and mem v journ and estim';
    con_info(12).vals = [-.5 .5 -.5 .5 0 0];
    
    con_info(13).name = 'estimate v journal';
    con_info(13).vals = [1 0 -1 0 0 0];
    con_info(14).name = 'estimate v imagine';
    con_info(14).vals = [1 -1 0 0 0 0];
    con_info(15).name = 'estimate v memory';
    con_info(15).vals = [1 0 0 -1 0 0];
    con_info(16).name = 'journal v estimate';
    con_info(16).vals = [-1 0 1 0 0 0];
    con_info(17).name = 'journal v imagine';
    con_info(17).vals = [0 -1 1 0 0 0];
    con_info(18).name = 'journal v memory';
    con_info(18).vals = [0 0 1 -1 0 0];
    
    con_info(19).name = 'journal v fixation';
    con_info(19).vals = [0 0 1 0 0 0 ];
    con_info(20).name = 'imagine v fixation';
    con_info(20).vals = [0 1 0 0 0 0 ];
    con_info(21).name = 'memory v fixation';
    con_info(21).vals = [0 0 0 1 0 0 ];
    con_info(22).name = 'estimate v fixation';
    con_info(22).vals = [1 0 0 0 0 0 ];
    
    con_info = con_info(1:22); % change con_info to reflect the total number of contrasts
   

    cd /younglab/studies/IEHFMRI/behavioural;
    save(all_dir(i).name);
    
    % save(all_dir(i).name,'-append','con_info'); %I think this line of
    % code will save new behavorial files with '-append.con_info', but I'm
    % fine with save the files without a new label (see line 81
    
    
end