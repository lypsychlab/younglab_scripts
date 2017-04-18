
function load_corrs_pleiades(cond_tag)
S=[3:20 22:24 27:35 38:42 44:47];
% cond_tag={'HARM' 'PURITY'};
% S=[3:47];
% cond_tag='LIFG_disgust';
% cond_tag='LIFG_disgweight_domain';

% cond_tag={'sixconds' 'fourcondsCross'};

ALL=struct();


    for subject=1:length(S)
        cd(fullfile('/home/younglw/server/englewood/mnt/englewood/data/PSYCH-PHYS',...
            ['SAX_DIS_' sprintf('%02d',S(subject))],'results/DIS_results_itemwise_normed'));
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
    % save(['all_corrs_LIFG_GROUP.mat'],'all_corrs');
    save(['all_regressinfo_' cond_tag '.mat'],'ALL');
end