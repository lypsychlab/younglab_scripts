bigC=zeros(39,5);
bigC_Z=zeros(39,5);
cd /younglab/scripts;
load('subjs_NT.mat');
for i=1:length(subj_names)
    if ~ismember(subj_names{i},subjs_NT)
        continue
    end
    cd(fullfile('/mnt/englewood/data/PSYCH-PHYS',subj_names{i},'results',...
        'DIS_results_itemwise_normed'));
    if exist('corrs_regression_RTPJ.mat') ~= 0
        load corrs_regression_RTPJ.mat;
        bigC(i,:)=corrs(:,1)';
        bigC_Z(i,:)=corrs_Z(:,1)';
        clear corrs;
        clear corrs_Z;
    end
end
save('/mnt/englewood/data/PSYCH-PHYS/corrs_RTPJ_12.15.mat','bigC','bigC_Z');
