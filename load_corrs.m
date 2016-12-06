
function load_corrs(rootdir,study,resdir,cond_tag,S)
% load_corrs: loads and saves aggregated values from RSA into a single file
% 
% Parameters:
% - rootdir: root directory
% - study: study directory
% - resdir: results directory where "regressinfo" files live
% - cond_tag: indicates which "regressinfo" files to load
% - S: array of subject numbers
% for paper analysis, S=[3:20 22:24 27:35 38:42 44:47];


ALL=struct();

    if S==0 %load default array of subjects
        S=[3:20 22:24 27:35 38:42 44:47];
    end

    for subject=1:length(S)
        cd(fullfile(rootdir,study,...
            ['SAX_DIS_' sprintf('%02d',S(subject))],'results',resdir));
        % change SAX_DIS if you have a different prefix for your subject folders
        try
            load(['regressinfo_' cond_tag '.mat'])
            num=length(ALL)+1;
            ALL(num).corrs=corrs;
            ALL(num).bint=bint;
            ALL(num).Rval=Rval;
            ALL(num).Rint=Rint;
            ALL(num).Stats=Stats;
            clear corrs bint Rval Rint Stats;
        catch
            disp(['Unable to process ' num2str(S(subject))]);
            continue
        end
    end
    cd(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS/results'));
    save(['all_regressinfo_' cond_tag '.mat'],'ALL');
end