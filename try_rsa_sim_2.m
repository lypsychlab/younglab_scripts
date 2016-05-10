tagnames={'1_0.01' '1_0.1' '1_0.5' '1_0.25' '1_1' '2_1' '2_1.5' '2_1.25' '2_1.75' '2_2' ...
    '3_2' '3_3' '3_4' '3_5' '3_6' '3_7' '3_8' '3_9' '3_10'};
all_data=[];
% all_P=[];
all_Rp=[];
for t=1:length(tagnames)
    all_Rp_sub=[];
    for s=3:47
        try
            [c,rp]=searchlight_all_roi_harm_sim('PSYCH-PHYS','SAX_DIS',tagnames{t},s,...
                24,'fake_24','RTPJ','_RTPJsim');
%             all_corrs=[all_corrs; c];
all_Rp_sub=[all_Rp_sub; rp];
        catch
            disp(['Did not process subject ' num2str(s)]);
            continue
        end
    end
    all_Rp=[all_Rp all_Rp_sub];
    savedir=fullfile('/mnt/englewood/data/PSYCH-PHYS/results/simulation/',tagnames{t});
%     mkdir(savedir);
cd(savedir);
    save(['all_corrs_' tagnames{t} '.mat'],'all_Rp_sub','-append');
%       load MVPA_data_simulated_RTPJ;
%       [h,p] = ttest(Z_wb(:,1),Z_wb(:,2));
%       all_P=[all_P p];
end