

% the FSL workaround
%run in matlab:
study='SHAPES';
subj='YOU_SHAPES_13';
directory = ['/younglab/studies/' study '/' subj '/3danat/'];
img = dir([directory 's0-0*-*-*-*.img']); %if this doesn't work, try .nii
maskthresh=0.4;
img=[directory img(1).name];
d=[directory 'skull_strip_mask'];
zip=[directory 'skull_strip_mask.nii.gz'];



% run in the system terminal (NOT matlab):
bet /younglab/studies/IEHFMRI/YOU_IEH_FMRI/3danat/s0-000-000-009.img /younglab/studies/IEHFMRI/YOU_IEH_FMRI/3danat/skull_strip_mask -f 0.40
gunzip /younglab/studies/IEHFMRI/YOU_IEH_FMRI/3danat/skull_strip_mask.nii.gz -f
% the formula is:
% bet (img) (d) -f (maskthresh)
% gunzip (zip) -f
% you can get the values for img, d, and zip into the terminal by copying and pasting

younglab_model_spm8_ieh('IEHFMRI','YOU_IEHFMRI_107','tom_localizer',[72 76],'unnormed')

%SHAPES_13
%younglab_model_spm8_ieh('SHAPES','YOU_SHAPES_13','tom_localizer',[9 11],'unnormed')
