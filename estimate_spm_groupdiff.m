function estimate_spm_groupdiff(loc,study,folders)


% if strcmp(loc,'englewood')
%     loc='/mnt/englewood/data';
% else
%     loc='/younglab/studies';
% end
con(1).vals=[1 -1];
con(2).vals=[-1 1];

for fold=1:length(folders)
    cd(fullfile(loc,study,'results',folders{fold}));

    load SPM;        
    spm_spm(SPM);
    clear SPM;

        cd(fullfile(loc,study,'results',folders{fold}));
        load SPM;        
        % con_vals = [1]
    for thisc=1:2

        if isempty(SPM.xCon)
            SPM.xCon = spm_FcUtil('Set', 'all', 'T', 'c', con(thisc).vals',SPM.xX.xKXs);
        else
            SPM.xCon(end+1) = spm_FcUtil('Set', 'all', 'T', 'c', con(thisc).vals',SPM.xX.xKXs);
        end
        
    end
    spm_contrasts(SPM);
    clear SPM;
end

end

