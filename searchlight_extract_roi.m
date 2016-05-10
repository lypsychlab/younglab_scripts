function [L] = searchlight_extract_roi(sub_nums,study,resdir,behav_tag_1,behav_tag_2,roiname,L)


subjs={};
for sub=1:length(sub_nums)
    subjs{end+1}=sprintf(['SAX_DIS_' '%02d'],sub_nums(sub));
end
rootdir ='/mnt/englewood/data/';
for s=1:length(subjs)

    cd(fullfile(rootdir,study,subjs{sub},'results',resdir));
    try
        interesting=['RSA_searchlight_' behav_tag_1 '_' roiname '.img'];
        boring=['RSA_searchlight_' behav_tag_2 '_' roiname '.img'];

        interesting = spm_vol(interesting);
        interesting = spm_read_vols(interesting);

        boring = spm_vol(boring);
        boring = spm_read_vols(boring);

        m1=mean(mean(mean(interesting)));
        m2=mean(mean(mean(boring)));

        L=[L;[m1 m2]];
    catch
        disp(['Excluding subject ' s]);
    end
end
end