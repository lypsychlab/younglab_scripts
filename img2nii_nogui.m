
function img2nii_nogui(study,subjs,prefix)
% img2nii_nogui: converts .img files to .niis
% without you having to resort to spmselect.
%
% Parameters:
% - study: study name
% - subjs: cell string of subject names
% - prefix: string prefix to indicate which image
% you'll be converting.
% E.g. 'ws' will convert the first smoothed normalized image
% in the structural directory.


    root_dir='/younglab/studies/';
    study_dir=fullfile(root_dir,study);

    for sub=1:length(subjs)
        cd(fullfile(study_dir,subjs{sub},'3danat'));
        anat_dir=dir([prefix '*.img']);
        if ~isempty(anat_dir)
            f=anat_dir(1).name;
            for i=1:size(f,1)
                input = deblank(f(i,:));
                [pathstr,fname,ext] = fileparts(input);
                output = strcat(fname,'.nii');
                V=spm_vol(input);
                ima=spm_read_vols(V);
                V.fname=output;
                spm_write_vol(V,ima);
            end
        end
    end


end
