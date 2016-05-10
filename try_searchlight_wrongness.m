function try_searchlight_wrongness(test_flag)
% clear all;
% cd /mnt/englewood/data/PSYCH-PHYS/behavioural;
% load subj_ids_key;
% test case:
if test_flag
    % searchlight_all_twomatrix_roi('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',3,48,3,'disgweight','domain','LIFG');
    sub=3;
    % searchlight_all_regress('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,[1:48],3,{'disgweight' 'domain' 'hother' 'hself'},'_domdisgharm')
else
    for sub=3:47
        try
        % searchlight_all('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,48,3,'wrongness','_wrong');
        % searchlight_all_onematrix('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,[0 24],3,'disgust','_h');
        % searchlight_all_onematrix_roi('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,48,3,'disgust','LIFG');
        % searchlight_all_regress_2('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,48,3,'disgustmean','domain','_domdisgmean');
        % searchlight_all_regress_2('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,48,3,'disgweight','domain','_domdisgweight');
        % searchlight_all_twomatrix_roi('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,48,3,'disgweight','domain','LIFG');
        % searchlight_all_regress('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,[1:48],3,{'disgweight' 'domain' 'hother' 'hself'},'_domdisgharm')
        searchlight_all_regress('PSYCH-PHYS','SAX_DIS','DIS_results_itemwise_normed',sub,[1:48],3,{'domain' 'hother' 'hself'},'_domharmNODISG')

        catch
            disp(['Could not process subject ' num2str(sub)]);
            continue
        end
    end
end
end %end function