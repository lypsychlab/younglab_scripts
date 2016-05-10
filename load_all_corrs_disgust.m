S=[3:20 22:24 27:35 38:42 44:47];
% cond_tag={'HARM' 'PURITY'};
% S=[3:47];
cond_tag='LIFG_disgust';
cond_tag='LIFG_disgweight_domain';


% for i=1:length(cond_tag)
    all_corrs=[];
%     all_corrs_Z=[];

    for subject=1:length(S)
        cd(fullfile('/mnt/englewood/data/PSYCH-PHYS',['SAX_DIS_' sprintf('%02d',S(subject))],'results/DIS_results_itemwise_normed'));
        try
            load(['corrs_' cond_tag '.mat'])
            all_corrs=[all_corrs; corrs];
%             all_corrs_Z=[all_corrs_Z; corrs_Z(:,1)'];
        catch
            disp(['Unable to process ' num2str(S(subject))]);
            all_corrs=[all_corrs; repmat([NaN],1,3)];
            % all_corrs=[all_corrs; repmat([NaN],1,5)];
%             all_corrs_Z=[all_corrs_Z; repmat([NaN],1,5)];

            continue
        end
    end
    cd /mnt/englewood/data/PSYCH-PHYS
    % save(['all_corrs_LIFG_GROUP.mat'],'all_corrs');
    save(['all_corrs_' cond_tag '.mat'],'all_corrs');

% end