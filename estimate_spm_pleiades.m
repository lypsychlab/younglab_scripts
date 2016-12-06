function estimate_spm_pleiades(loc,study,folders)


% if strcmp(loc,'englewood')
%     loc='/mnt/englewood/data';
% else
%     loc='/younglab/studies';
% end

for fold=1:length(folders)
        cd(fullfile(loc,study,'results',folders{fold}));

        load SPM;        
        spm_spm(SPM);
        clear SPM; load SPM;
        con_vals = [1];
        if isempty(SPM.xCon)
            SPM.xCon = spm_FcUtil('Set', 'all', 'T', 'c', con_vals,SPM.xX.xKXs);
        else
            SPM.xCon(end+1) = spm_FcUtil('Set', 'all', 'T', 'c', con_vals,SPM.xX.xKXs);
        end
        spm_contrasts(SPM);
        clear SPM;
end

end

