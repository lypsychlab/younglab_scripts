% create new contrasts for DIS_results_unnormed SPM.mat files that will
% separate the odd from the even runs of DIS for use with Jorie's MVPA
% script

% 
% Amelia_younglab_create_contrast('Even accidental-harm', {'[246]*ACCH*'},[1])
% Amelia_younglab_create_contrast('Odd accidental-harm', {'[135]*ACCH*'},[1])
% Amelia_younglab_create_contrast('Even intentional-harm', {'[246]*INTH*'},[1])
% Amelia_younglab_create_contrast('Odd intentional-harm', {'[135]*INTH*'},[1])
% Amelia_younglab_create_contrast('Even accidental-purity', {'[246]*ACCP*'},[1])
% Amelia_younglab_create_contrast('Odd accidental-purity', {'[135]*ACCP*'},[1])
% Amelia_younglab_create_contrast('Even intentional-purity', {'[246]*INTP*'},[1])
% Amelia_younglab_create_contrast('Odd intentional-purity', {'[135]*INTP*'},[1])


% Amelia_younglab_create_contrast('Even_purity', {'[246]*PURITY*'},[1])
% Amelia_younglab_create_contrast('Odd_purity', {'[135]*PURITY*'},[1])
% Amelia_younglab_create_contrast('Even_harm', {'[246]*HARM*'},[1])
% Amelia_younglab_create_contrast('Odd_harm', {'[135]*HARM*'},[1])

% Below is what was used to create contrasts for the (smoothed, normed)
% Jorie model for subject 38; 12/4/14

% Amelia_younglab_create_contrast('Even intentional harm', {'[246]*PHI*', '[246]*PSI*'},[1 1])
% Amelia_younglab_create_contrast('Odd intentional harm', {'[135]*PHI*', '[135]*PSI*'},[1 1])
% Amelia_younglab_create_contrast('Even accidental harm', {'[246]*PHA*', '[246]*PSA*'},[1 1])
% Amelia_younglab_create_contrast('Odd accidental harm', {'[135]*PHA*', '[135]*PSA*'},[1 1])
% 
% % Amelia_younglab_create_contrast('Even accidental purity', {'[246]*ACCP*'},[1])
% % Amelia_younglab_create_contrast('Odd accidental purity', {'[135]*ACCP*'},[1])
% % Amelia_younglab_create_contrast('Even intentional purity', {'[246]*INTP*'},[1])
% % Amelia_younglab_create_contrast('Odd intentional purity', {'[135]*INTP*'},[1])
% 
% % Below is what was used to create contrasts for putting Jorie's DIS model
% % into Jordan's MVPA script. 
% 
% Amelia_younglab_create_contrast('intentional_harm', {'[123456]*PHI*', '[123456]*PSI*'},[1 1])
% Amelia_younglab_create_contrast('accidental_harm', {'[123456]*PHA*', '[123456]*PSA*'},[1 1])

Amelia_younglab_create_contrast('Even_int-phys-harm', {'[246]*PHI*'},[1])
Amelia_younglab_create_contrast('Odd_int-phys-harm', {'[135]*PHI*'},[1])
Amelia_younglab_create_contrast('Even_acc-phys-harm', {'[246]*PHA*'},[1])
Amelia_younglab_create_contrast('Odd_acc-phys-harm', {'[135]*PHA*'},[1])
Amelia_younglab_create_contrast('Even_int-psy-harm', {'[246]*PSI*'},[1])
Amelia_younglab_create_contrast('Odd_int-psy-harm', {'[135]*PSI*'},[1])
Amelia_younglab_create_contrast('Even_acc-psy-harm', {'[246]*PSA*'},[1])
Amelia_younglab_create_contrast('Odd_acc-psy-harm', {'[135]*PSA*'},[1])