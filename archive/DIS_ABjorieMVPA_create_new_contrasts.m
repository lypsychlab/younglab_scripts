%SHOULD BE OK TO USE ON PLEIADES 8/19/14

% create new contrasts for DIS_results_unnormed SPM.mat files that will
% separate the odd from the even runs of DIS for use with Jorie's MVPA
% script


Amelia_younglab_create_contrast('Even_accidental-harm', {'[246]*ACCH*'},[1])
Amelia_younglab_create_contrast('Odd_accidental-harm', {'[135]*ACCH*'},[1])
Amelia_younglab_create_contrast('Even_intentional-harm', {'[246]*INTH*'},[1])
Amelia_younglab_create_contrast('Odd_intentional-harm', {'[135]*INTH*'},[1])
Amelia_younglab_create_contrast('Even_accidental-purity', {'[246]*ACCP*'},[1])
Amelia_younglab_create_contrast('Odd_accidental-purity', {'[135]*ACCP*'},[1])
Amelia_younglab_create_contrast('Even_intentional-purity', {'[246]*INTP*'},[1])
Amelia_younglab_create_contrast('Odd_intentional-purity', {'[135]*INTP*'},[1])


% Amelia_younglab_create_contrast('Even_purity', {'[246]*PURITY*'},[1])
% Amelia_younglab_create_contrast('Odd_purity', {'[135]*PURITY*'},[1])
% Amelia_younglab_create_contrast('Even_harm', {'[246]*HARM*'},[1])
% Amelia_younglab_create_contrast('Odd_harm', {'[135]*HARM*'},[1])

