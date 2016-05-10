function searchlight_mask(sub_nums,study,resdir,behav_tag,roiname)


subjs={};
for sub=1:length(sub_nums)
    subjs{end+1}=sprintf(['SAX_DIS_' '%02d'],sub_nums(sub));
end
rootdir ='/mnt/englewood/data/';

for sub=1:length(subjs)
    cd(fullfile(rootdir,study,subjs{sub},'roi'));
    roidir=dir(['ROI_' roiname '*img']);
    if isempty(roidir)
        disp(['No ' roiname ' for subject ' subjs{sub}]);
        continue
    end
    mask_img=spm_vol(roidir(1).name);
    mask_img.fname=fullfile(pwd,mask_img.fname);
    
    cd ..
    cd results
    cd(resdir);
    
    V_in=spm_vol(['RSA_searchlight_' behav_tag '.img']);
    V_in_array=[mask_img;V_in];
    V_out=V_in;
    V_out.fname=['RSA_searchlight_' behav_tag '_' roiname '.img'];
    
    fun = 'i1.*i2';
    
    spm_imcalc(V_in_array,V_out,fun);
end

end