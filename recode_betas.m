% for s=3:47
s=3;
    try
        cd(fullfile('/mnt/englewood/data/PSYCH-PHYS/',sprintf(['SAX_DIS_' '%02d'],s),'results/DIS_results_itemwise_normed'));
        for c=1:9
            d=dir(['beta_item_' num2str(c) '_*nii']);
            movefile(d(1).name,['beta_item_' sprintf('%02d',c) d(1).name(end-7:end)]);
        end
    catch
        disp(['Failed for subject ' num2str(s)]);
    end
% end