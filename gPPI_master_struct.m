root_dir='/younglab/studies/';
study='IEHFMRI';
rois={'RTPJ' 'DMPFC'};

P.subject='YOU_IEHFMRI_105';
P.directory=fullfile(root_dir,study,P.subject,'results',...
    'ieh_results_normed_Dur60');
cd(fullfile(root_dir,study,P.subject,'roi'));
d1=dir(['ROI*' rois{1} '*img']);
d2=dir(['ROI*' rois{2} '*img']);
P.Region=[rois{1} ' ' rois{2}];
P.VOI=fullfile(pwd,d1(1).name);
P.VOI2=fullfile(pwd,d2(1).name);
P.analysis='phy'; % options: 'psy','phy','psyphy'
P.method='cond';

P.Tasks={'1' 'Estimate' 'Imagine' 'Journal' 'Memory' ...
    'difficultyTR' 'storyTR'};

P.Estimate=1;
P.contrast=0;
P.extract='eig';
P.Weights=[];
P.CompContrasts=1;
P.Weighted=0;

tasks=P.Tasks(2:end-2);
v=1:length(tasks);C=nchoosek(v,2);
for c=1:length(C)
    contrast_name=[tasks{C(c,1)} '_>_' tasks{C(c,2)}];
    P.Contrasts(c).left={tasks(C(c,1))};
    P.Contrasts(c).right={tasks(C(c,2))};
    P.Contrasts(c).STAT='T';
    P.Contrasts(c).Weighted=0;
    P.Contrasts(c).MinEvents=1;
    P.Contrasts(c).name=contrast_name;
end

cd ..;
save(['P_' P.subject '.mat'],'P');