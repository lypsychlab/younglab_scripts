
addpath(genpath('/usr/public/spm/spm12'));
EXPERIMENT_ROOT_DIR = '/home/younglw';
study='VERBS';
for subnum=3:47
    try
        disp(['Processing subject ' sprintf('%02d',subnum) '...']);
        load(fullfile(EXPERIMENT_ROOT_DIR,study,'behavioural',['SAX_DIS_' sprintf('%02d',subnum) '.DIS_verbint1.1.mat']),'con_info');
        cd(fullfile(EXPERIMENT_ROOT_DIR,study,['SAX_DIS_' sprintf('%02d',subnum)],'results/DIS_verbint1_results_concat_normed'));
        load('SPM.mat');
        total_len=length(SPM.Vbeta);
        for thiscon=1:length(con_info)
            if length(con_info(thiscon).vals)<total_len
                con_info(thiscon).vals = [con_info(thiscon).vals zeros(1,total_len-length(con_info(thiscon).vals))];
            end
            if isempty(SPM.xCon)
                SPM.xCon=spm_FcUtil('Set', con_info(thiscon).name{1}, 'T', 'c', con_info(thiscon).vals',SPM.xX.xKXs);
            else
                SPM.xCon(end+1)=spm_FcUtil('Set', con_info(thiscon).name{1}, 'T', 'c', con_info(thiscon).vals',SPM.xX.xKXs);
            end
        end
        clear con_info;
        disp('Making contrasts...');
        spm_contrasts_pleiades(SPM);
        disp('Done.')
    catch
        disp(['Could not run contrasts for subject ' sprintf('%02d',subnum)]);
        continue
    end
end

