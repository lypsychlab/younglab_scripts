function DIS_mvpa_ab_100114()

% edited Jan 22, 2014 (replicating Jorie's DIS mvpa)
% by Amelia

roiFiles = {'RTPJ'}; %,'DMPFC','RTPJ','LTPJ','RSTS','LSTS','MMPFC'}; % {'PC','DMPFC','RTPJ'};
group = 0;
group_loc = '/younglab/roi_library/newrois';
parametric = 1; 

experiments=struct(...
    'name','DIS_MVPA',... % study name
    'pwd1','/younglab/studies/DIS_MVPA/',...   % folder with participants 
    'pwd2','results/DIS_results_normed/',...   % inside each participant, path to SPM.mat
    'data',{{'SAX_DIS_03','SAX_DIS_04','SAX_DIS_05','SAX_DIS_06','SAX_DIS_07','SAX_DIS_08','SAX_DIS_09','SAX_DIS_10','SAX_DIS_11','SAX_DIS_12','SAX_DIS_13','SAX_DIS_14','SAX_DIS_27','SAX_DIS_28',...
    'SAX_DIS_32','SAX_DIS_34'}});
   
    % in the previous attempt to replicate Jorie's data: 
    % subjects SAX_DIS_27, SAX_DIS_32, and SAX_DIS_34 were missing rtpj in
    % unormed images
    % subjects SAX_DIS_14, SAX_DIS_43, and SAX_DIS_46 were missing trials
 
partition_names={'Even ','Odd '};

 condition_names_all={{'intentional harm','accidental harm'}%,... XXXcheck shapes and stop here
%     {'accidental-harm','intentional-harm','accidental-purity','intentional-purity'}
%     {'purity','harm'}
%      {'coop','control-coop'},...
%      {'defect','control-defect'},...
%      {'control-coop','control-defect'},...
%      {'match','mismatch'}
};

 % Possible conditions: -- Even con # | Odd con #
 % coop -- 19 | 20
 % defect -- 21 | 22
 % control-coop -- 23 | 24
 % control-defect -- 25 | 26
 % match -- 27 | 28
 % mismatch -- 29 | 30
 % 

for i=1:length(roiFiles)
    roin = roiFiles{i};
    roinum = i;
    savedirectory = '/younglab/studies/DIS_MVPA/MVPA_replicate/MVPA_domint_noTSC_smoothed_normed_n16_nondirectional';
    mkdir(savedirectory);
    mkdir(savedirectory,'MVPA_images');
    analyMVPA_general_nondirectional_real(roin, experiments,partition_names,condition_names_all,savedirectory, roinum, group, group_loc,parametric);
    
%     savedirectory = '/younglab/studies/DIS/MVPA_replicate/MVPA_domain_directional';
%     mkdir(savedirectory);
%     mkdir(savedirectory,'MVPA_images');
%     analyMVPA_general(roin, experiments,partition_names,condition_names_all,savedirectory, roinum, group, group_loc,parametric);
% %     analyMVPA_general_nondirectional(roin, experiments,partition_names,condition_names_all,savedirectory, roinum, group, group_loc,parametric);
end